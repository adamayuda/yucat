# Onboarding — the first-run funnel

Everything about YuCat's first-run experience: the phase machine, the cascade that leaves
the bloc, the two analytics funnel contracts, and the traps.

This is the source of truth for `lib/features/onboarding/`. It deliberately does **not**
describe individual screens — those churn weekly and the code makes them obvious. What's
here is the stuff that spans files.

> **Why this feature has a doc and others don't:** onboarding's last four beats aren't in
> `OnBoardingBloc` at all. They're a router push-chain through three other features, wired
> by callbacks. No single file shows the flow.

---

## 1. Shape of the thing

```
main.dart ─ MultiBlocProvider owns OnBoardingBloc (app-scoped, NOT page-scoped)
   │
SplashRoute ── onboarding_completed != true ──► OnBoardingRoute
   │
   └─ OnBoardingPage: one PageView over the 12-value OnBoardingPhase enum
        │  (physics: NeverScrollableScrollPhysics — the bloc drives paging)
        └─ phase 11 `healthIntro` CTA ──► the cascade (§3), which leaves the bloc
```

Two states only — `OnBoardingLoadingState` and `OnBoardingReadyState`. **The state machine
is not in the states**: it's the `OnBoardingPhase` enum plus two hand-written `switch`
transition tables in `_onOnBoardingAdvancePhaseEvent` / `_onOnBoardingPreviousPhaseEvent`.
`OnBoardingReadyState` carries `phase`, `selectedSource`, `seededName`, `seededPhotoPath`,
`catSummary`.

---

## 2. The 12 phases

`OnBoardingPhase` in `bloc/onboarding_state.dart`. **Declaration order is simultaneously the
page order and the analytics index** — `OnBoardingPage` pages via
`OnBoardingPhase.values.indexOf(state.phase)`.

| # | Phase | Advances via |
|---|---|---|
| 0 | `welcome` | `OnBoardingGetStartedEvent` |
| 1 | `scanDemo` | `OnBoardingAdvancePhaseEvent` |
| 2 | `attribution` | `AttributionSelectedEvent` / `AttributionSkippedEvent` — **both jump to `proofChart`** |
| 3 | `proofChart` | advance |
| 4 | `whyYucat` | advance |
| 5 | `nutritionFact` | advance |
| 6 | `profileIntro` | advance |
| 7 | `profileName` | `NameSeededEvent` + advance — **seeds the wizard** |
| 8 | `rating` | advance (fires the App Store review modal — §5) |
| 9 | `notifPrimer` | advance (**mock**, requests nothing — §5) |
| 10 | `reminders` | advance (**real** OS push prompt, iOS only — §5) |
| 11 | `healthIntro` | `OnBoardingCompletedEvent` → §3 |

> ### ⚠️ The enum ordinal is a Mixpanel funnel contract
>
> `_trackPhaseView` emits `step_index = OnBoardingPhase.values.indexOf(phase)` on
> **`Onboarding Step Viewed`**, and that index builds the onboarding funnel and
> mid-onboarding drop-off report. **Reordering or inserting a phase silently renumbers
> every historical funnel step** — old and new data land in the same bucket with different
> meanings. Nothing warns you at the enum definition site.
>
> If you must insert a phase, treat it as a breaking analytics change: coordinate with
> whoever owns the Mixpanel funnels first.

Note `attribution` has no `advance` transition — both its events hard-code `proofChart` as
the next phase, so the `AdvancePhaseEvent` switch has no `attribution` case.

---

## 3. The cascade — after `healthIntro` the flow leaves the bloc

This is the expensive part to reconstruct. Four beats, three callback hops, four files:

```
healthIntro "Add my cat"
  └─► OnBoardingCompletedEvent
        └─► router.push CreateCatRoute(seededName, seededPhotoPath, onCreated:)
              │                                          [features/cat_create]
              └─► onCreated(wizardContext, summary):
                    ├─ _prefs.setBool('onboarding_completed', true)   ◄── HERE, not at the end
                    │
                    ├─ if !RemoteConfigService.onboardingScanEnabled
                    │     └─► OnBoardingFinalizedEvent            (skip scan + result)
                    │
                    └─ else router.push CurrentFoodRoute(summary, onStart:)
                          │                    [onboarding/widgets/current_food_screen]
                          └─► scan or skip → router.replace ResultRoute(...)
                                │                  [onboarding/widgets/result_screen]
                                └─► "Start scanning" → onStart(resultContext)
                                      └─► OnBoardingFinalizedEvent
                                            ├─ 'Onboarding Completed' + markOnboardingComplete()
                                            ├─ await push PaywallRoute(dismissible: false)
                                            │     ↑ blocks until subscribed/restored
                                            └─ replaceAll([MainRoute(children: [HomeRoute()])])
```

Three consequences that bite:

1. **`onboarding_completed` is written when the cat is created** — before the scan, the
   result screen and the paywall. A user who quits on the result screen is "onboarded", so
   next launch they hit the **splash** paywall gate instead of resuming onboarding. That is
   intentional (the cat is the asset worth keeping) but it means "completed onboarding" in
   SharedPreferences ≠ "saw the whole funnel", and the `Onboarding Completed` *event* fires
   at a different moment than the *flag*.
2. **`replaceAll`, not `replace`, with Home explicitly activated.** By the time we finalize,
   the stack holds onboarding → wizard → result. `replaceAll` clears all of it; passing
   `children: [HomeRoute()]` picks the Home tab rather than the default first tab (Search),
   matching the splash flow.
3. **`CurrentFoodScreen` uses `replace`, not `push`,** to reach the result screen — so the
   scan screen is gone from the stack and the result screen's back gesture doesn't return
   to a dead scanner.

`kTestBuildSkipPaywall` (`lib/config/test_flags.dart`) skips the paywall push entirely.

---

## 4. The remote kill switch

`RemoteConfigService.onboardingScanEnabled` — Firebase Remote Config key
**`onboarding_scan_enabled`**, default `true`, **fail-open** (a fetch failure leaves the scan
enabled), 1 h minimum fetch interval.

Flipping it to `false` in the Firebase console drops the `CurrentFoodRoute` → `ResultRoute`
beats for **new onboarding sessions**, finalizing straight from the wizard to the paywall —
no build, no review. It exists so the Anthropic-backed scan can be switched off if the
backend degrades or gets expensive.

This is the **only** consumer of the flag in the app.

---

## 5. Screen-level traps

### `rating` (phase 8) — burns Apple's review budget outside the gate

`rating_screen.dart:_handleNext` calls `InAppReview.instance.requestReview()` **directly**.
That bypasses `ReviewPromptService` (`_minScansBeforeFirstPrompt = 5`,
`_minDaysBetweenPrompts = 90`), which exists specifically so we don't burn the budget on
low-intent moments. **Apple allows 3 modals per 365 days per user**, and every new user
spends one here — before they have used the product at all.

It also **hard-waits 3 seconds**: `SKStoreReviewController` gives no completion callback and
doesn't background the app, so there's no signal for when the user finishes. The screen shows
a spinner and delays so the popup isn't yanked away. Failures are swallowed — advancing must
never depend on the prompt.

### `notifPrimer` (9) is a mock; `reminders` (10) is real

- `notif_primer_screen.dart` is **MOCK ONLY** (says so at the top, with a `TODO`) — it
  previews the value of alerts and requests **no** permission.
- `reminders_screen.dart:_onDone` calls the real `NotificationService.requestPermission()`
  → `OneSignal.Notifications.requestPermission(true)`, which is **iOS-only**
  (`if (!Platform.isIOS) return false`). Emits `Notifications Opted In` / `Opted Out` with
  `source: 'onboarding_reminders'`.
- ⚠️ **The reminder-type selections are never persisted.** They're a local
  `Set<int> _selected` used only to style the rows. Nothing reads them, and no reminder is
  ever scheduled — the app has no local-notification scheduling at all.
- ⚠️ **This screen's position bounds all push reach.** Permission is asked at phase 10 of
  12, so anyone abandoning in phases 0–9 has no push subscription and cannot be messaged —
  including by the OneSignal drop-off segments. `_trackPhaseView` still writes a
  `funnel_stage` tag for them. See `docs/onesignal.md` §3.

### `profileName` (7) seeds the wizard

The name goes into `seededName`, so the cat-create wizard **starts at step 1** and rebases
its progress bar to 11 steps instead of 12. See `lib/features/cat_create/README.md` §2.

---

## 6. The onboarding scan is a separate analytics namespace

Same user action as Home's scan, different event names by surface. Both sets are live; don't
merge them without checking the funnels.

| Onboarding (`current_food_screen.dart`) | Home (`home_bloc.dart`) |
|---|---|
| `Onboarding Scan Captured` | `Product Image Captured` |
| `Onboarding Scan Succeeded` (`product`, `score`) | `Product Selected` |
| `Onboarding Scan Failed` (`error_type`, `error_message`) | `Product Image Scan Failed` |
| `Onboarding Scan Skipped` (`phase`: `intro` \| `error`) | — |

⚠️ **The error classifier is duplicated.** `CurrentFoodScreen._errorType` returns a
`String`; `HomeBloc._toErrorType` returns a `HomeErrorType` enum and additionally checks
`e is FirebaseFunctionsException`. The onboarding copy is deliberately string-based so the
screen needs no `cloud_functions` import. Both must classify identically or the `error_type`
dimension splits across surfaces.

Other onboarding events: `Onboarding Started` (`source: 'first_launch'`),
`Onboarding Get Started Tapped`, `Onboarding Step Viewed`, `Onboarding Step Back`
(`from_phase`, `to_phase`), `Onboarding Attribution Selected` / `Skipped`,
`Onboarding Completed` (`total_time_seconds`, `steps_viewed`, `attribution_source`).

`Onboarding Skipped` **does not exist** despite appearing in older docs.

Attribution also writes a Mixpanel **People property** via
`UserAnalyticsService.setAttribution(source)` — that's what makes attribution a segment on
every funnel, not just an event.

---

## 7. Recommendations warm-up

`CurrentFoodScreen._runScan` fires `unawaited(recommendProductsForCat(...))` on scan success —
one screen *before* the result screen needs it — so the locked-picks teaser is instant.

That cache is a **module-level `Map<String, List<ProductPick>>` keyed by cat id** in
`lib/features/cat/presentation/utils/cat_product_recommendations.dart`. Process-global and
session-lived: it is invalidated only by `invalidateProductPicksCache(catId)`, which
`CatCreateBloc` calls after an edit. Nothing else refreshes it, so picks otherwise persist
until app restart.

Thresholds worth knowing before you tune them (comments in that file explain the rationale —
therapeutic/vet diets land at 72+, while cheap foods with good-looking macros sit ~52 and are
correctly excluded):

| Constant | Value | Meaning |
|---|---|---|
| `_minBaseScore` | 70 | Product must be a decent food in general |
| `_minFit` | 68 | Per-cat fit floor — "not wrong for this cat" |
| `_poolPerQuery` | 40 | Algolia candidates per query |
| `_poolCacheSize` | 10 | Picks retained per cat |

---

## 8. Gotchas in the page itself

- **Never `close()` the bloc.** `OnBoardingBloc` is owned by the root `MultiBlocProvider` in
  `main.dart`. `OnBoardingPage.dispose()` disposes only the `PageController` — closing the
  bloc would make re-mounting the page add events to a closed bloc.
- **The proof-chart Lottie is pre-warmed** in `didChangeDependencies` (guarded by
  `_assetsWarmed`) because decoding it on the frame the page slides in caused visible jank.
- **`countryCode` is the device region, not the app locale** —
  `platformDispatcher.locale.countryCode`, passed to the backend to bias `web_search` to the
  user's market. Same source as `scanner_page.dart`. A user with a Spanish phone reading
  English still gets ES-biased results, which is what we want.

### Dead code — registered but never dispatched

Don't hunt for the dispatcher; there isn't one.

- **`OnBoardingPhotoSeededEvent`** — handled in the bloc, dispatched nowhere. So
  `state.seededPhotoPath` is always `null`, which makes `CreateCatPage`'s `seededPhotoPath`
  parameter and its `File(...)` branch **unreachable from onboarding**.
- **`OnBoardingBackToWelcomeEvent`** — handled, never dispatched. Back navigation goes
  through `OnBoardingPreviousPhaseEvent` (the `BackChip`).

`OnBoardingNameSeededEvent` *is* live (`onboarding_page.dart:172`).

---

## 9. Where the flow is documented elsewhere

- **`docs/design.md` §9** — the same flow from the design side, with the gradient tokens
  per beat. §10 covers the cat-create wizard's two contexts.
- **`lib/features/paywall/README.md`** — the paywall gate this flow ends at, and the
  matching splash gate for returning users.
- **`lib/features/cat_create/README.md`** — the wizard this flow hands off to: the 12-step
  table, the second `step_index` funnel contract, and why its bloc is session-scoped.
- **Root `CLAUDE.md`** — the `CatEntity` field table and the analytics summary.
