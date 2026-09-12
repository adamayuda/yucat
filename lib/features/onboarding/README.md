# Onboarding — the first-run funnel

Everything about YuCat's first-run experience: the phase machine, the cascade that leaves
the bloc, the two analytics funnel contracts, and the traps.

This is the source of truth for `lib/features/onboarding/`. It deliberately does **not**
describe individual screens — those churn weekly and the code makes them obvious. What's
here is the stuff that spans files.

> **Why this feature has a doc and others don't:** onboarding's last two beats aren't in
> `OnBoardingBloc` at all. They're a router push-chain through two other features, wired
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
| 2 | `recipesArticles` | `OnBoardingAdvancePhaseEvent` |
| 3 | `proofChart` | advance |
| 4 | `whyYucat` | advance |
| 5 | `nutritionFact` | advance |
| 6 | `profileIntro` | advance |
| 7 | `profileName` | `NameSeededEvent` + advance — **seeds the wizard** |
| 8 | `rating` | advance (fires the App Store review modal — §4) |
| 9 | `notifPrimer` | advance (**mock**, requests nothing — §4) |
| 10 | `reminders` | advance (**real** OS push prompt, iOS only — §4) |
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

> ### Phase 2 was `attribution`, and the screen is parked, not deleted
>
> `recipesArticles` replaced the "How did you hear about us?" screen **in the same slot**, so
> every `step_index` is unchanged and the funnels below survive. Only `step_name` at index 2
> differs. `attribution_screen.dart`, `OnBoardingAttributionSelectedEvent` / `SkippedEvent`,
> their bloc handlers, `OnBoardingReadyState.selectedSource` and the six
> `onboardingAttribution*` ARB keys are all still here and still compile — nothing dispatches
> them. Reviving attribution means restoring one `case` in `onboarding_page.dart` (and giving
> it a slot). Until then `attribution_source` is null everywhere.
>
> Note the old phase had **no `advance` transition** — both its events hard-coded `proofChart`.
> `recipesArticles` uses the generic advance, so the `AdvancePhaseEvent` switch now has a
> `recipesArticles => proofChart` case that did not exist before.

---

## 3. The cascade — after `healthIntro` the flow leaves the bloc

Two beats, one callback hop, three files:

```
healthIntro "Add my cat"
  └─► OnBoardingCompletedEvent
        └─► router.push CreateCatRoute(seededName, seededPhotoPath, onCreated:)
              │                                          [features/cat_create]
              └─► onCreated(wizardContext, _):
                    ├─ _prefs.setBool('onboarding_completed', true)   ◄── HERE
                    └─► OnBoardingFinalizedEvent
                          ├─ 'Onboarding Completed' + markOnboardingComplete()
                          ├─ await push PaywallRoute(dismissible: false)
                          │     ↑ blocks until subscribed/restored
                          └─ replaceAll([MainRoute(children: [HomeRoute()])])
```

Two consequences that bite:

1. **`onboarding_completed` is written when the cat is created** — before the paywall. A
   user who kills the app at the paywall is "onboarded", so next launch they hit the
   **splash** paywall gate instead of resuming onboarding. That is intentional (the cat is
   the asset worth keeping) but it means "completed onboarding" in SharedPreferences ≠
   "saw the whole funnel", and the `Onboarding Completed` *event* fires at a different
   moment than the *flag*.
2. **`replaceAll`, not `replace`, with Home explicitly activated.** By the time we finalize,
   the stack holds onboarding → wizard. `replaceAll` clears both; passing
   `children: [HomeRoute()]` picks the Home tab rather than the default first tab (Search),
   matching the splash flow.

`kTestBuildSkipPaywall` (`lib/config/test_flags.dart`) skips the paywall push entirely.

### The scan + result beats are gone

Until 2026-09-12 two more beats sat between the wizard and the paywall: `CurrentFoodRoute`
(scan the cat's current food) → `ResultRoute` (verdict + locked picks teaser), gated by the
Remote Config key `onboarding_scan_enabled`. The flag had been off in production for months
(131 users ever reached the scan against 1,300 onboarding starts in the same window) while
the fail-open debug default kept showing the beat on every test build. The screens, routes,
the flag, the `Onboarding Scan …` events and the 18 ARB keys were all deleted; historical
event rows remain in Mixpanel. The Remote Config key can be removed from the console.

---

## 4. Screen-level traps

### `recipesArticles` (phase 2) — the app's only perpetual animation on a long-lived page

`RecipesMarquee` drifts three columns of photos continuously (outer down, middle up) behind the
headline. Three things about it are load-bearing:

- ⚠️ **It must be paused when the phase isn't visible.** `PageView.builder` is lazy, but the
  280 ms `animateToPage` sweeps the scroll position across every intervening page — mounting each
  — and the neighbour stays mounted afterwards. Flutter's `PageView` does **not** wrap children in
  a disabled `TickerMode`, so a mounted-but-off-screen marquee keeps ticking at full frame cost.
  `onboarding_page.dart` passes `active: phase == currentPhase` and the widget starts/stops its
  controller on both edges in `didUpdateWidget` — the same shape `ProfileNameScreen` uses for the
  keyboard. **Drop that flag and you get a permanent background animation nobody can see.**

  Every other perpetual loop in the app (`MascotIllustration`, the scanner reticle,
  `HomeLoadingPage`) lives on an ephemeral screen and stops by being unmounted, which is why none
  of them needed this and there was no machinery to reuse.

- **Tile aspect ratios are hardcoded** in `_Tile`, so column heights are known at layout time.
  Measuring would mean decoding first — a frame late, with a visible jump. If you swap an asset,
  update its ratio or the loop seam becomes visible.

- **The seam is invisible only because each column renders its tiles twice** and translates by
  exactly one copy's height, gaps included. A visible jump at the wrap means `cycleHeight`
  disagrees with what's actually laid out.

It also honours `MediaQuery.disableAnimationsOf` — the only place in the app that reads it.

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
  `Set<int> _selected` used only to style the rows. They were tags for one day
  (2026-09-12) and were dropped to fit the OneSignal Free plan's 6-tag budget; no reminder
  is ever scheduled — the app has no local-notification scheduling at all.
- ⚠️ **This screen's position bounds all push reach.** Permission is asked at phase 10 of
  12, so anyone abandoning in phases 0–9 has no push subscription and cannot be messaged —
  including by the OneSignal drop-off segments. `_trackPhaseView` still writes a
  `funnel_stage` tag for them. See `docs/onesignal.md` §3.

### `profileName` (7) seeds the wizard

The name goes into `seededName`, so the cat-create wizard **starts at step 1** and rebases
its progress bar to 11 steps instead of 12. See `lib/features/cat_create/README.md` §2.

---

## 5. Analytics

`Onboarding Started` (`source: 'first_launch'`), `Onboarding Get Started Tapped`,
`Onboarding Step Viewed`, `Onboarding Step Back` (`from_phase`, `to_phase`),
`Onboarding Completed` (`total_time_seconds`, `steps_viewed`, `attribution_source`).

`Onboarding Skipped` **does not exist** despite appearing in older docs. The
`Onboarding Scan Captured / Succeeded / Failed / Skipped` namespace was deleted with the
scan beat (§3) — historical rows only.

⚠️ **`Onboarding Attribution Selected` / `Skipped` are now unreachable**, and with them
`UserAnalyticsService.setAttribution(source)` — the Mixpanel **People property** that made
attribution a segment on every funnel. `attribution_source` is null on `Onboarding Completed`
and unset on every new user. The code is parked (§2), so this is reversible, but no channel
data is being collected in the meantime.

---

## 6. Gotchas in the page itself

- **Never `close()` the bloc.** `OnBoardingBloc` is owned by the root `MultiBlocProvider` in
  `main.dart`. `OnBoardingPage.dispose()` disposes only the `PageController` — closing the
  bloc would make re-mounting the page add events to a closed bloc.
- **The proof-chart Lottie is pre-warmed** in `didChangeDependencies` (guarded by
  `_assetsWarmed`) because decoding it on the frame the page slides in caused visible jank.

### Dead code — registered but never dispatched

Don't hunt for the dispatcher; there isn't one.

- **`OnBoardingPhotoSeededEvent`** — handled in the bloc, dispatched nowhere. So
  `state.seededPhotoPath` is always `null`, which makes `CreateCatPage`'s `seededPhotoPath`
  parameter and its `File(...)` branch **unreachable from onboarding**.
- **`OnBoardingBackToWelcomeEvent`** — handled, never dispatched. Back navigation goes
  through `OnBoardingPreviousPhaseEvent` (the `BackChip`).

`OnBoardingNameSeededEvent` *is* live (`onboarding_page.dart:172`).

---

## 7. Where the flow is documented elsewhere

- **`docs/design.md` §9** — the same flow from the design side, with the gradient tokens
  per beat. §10 covers the cat-create wizard's two contexts.
- **`lib/features/paywall/README.md`** — the paywall gate this flow ends at, and the
  matching splash gate for returning users.
- **`lib/features/cat_create/README.md`** — the wizard this flow hands off to: the 12-step
  table, the second `step_index` funnel contract, and why its bloc is session-scoped.
- **Root `CLAUDE.md`** — the `CatEntity` field table and the analytics summary.
