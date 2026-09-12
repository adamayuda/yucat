# OneSignal / Push Notifications

Everything about push in YuCat: what's wired, the tag schema, the Segments it enables,
and the constraints that decide who can actually be reached.

> **Source of truth for push.** `CLAUDE.md`, `docs/design.md` §12 and
> `lib/features/onboarding/README.md` §5 all defer here.

---

## 1. What it is

Push is **iOS-only**, via [`onesignal_flutter`](https://pub.dev/packages/onesignal_flutter)
`^5.5.8` (resolving to `OneSignalXCFramework 5.5.2`). Android has **nothing** — no gradle
dependency, no manifest entry, no app id. Every method in the service is guarded with
`Platform.isIOS`, so the whole subsystem is a silent no-op there. This mirrors the
original iOS-first posture.

The app never touches the OneSignal SDK directly. Everything goes through
`lib/services/notification_service.dart`.

| Thing | Value |
|---|---|
| App ID | `2a0ad1ef-59ab-43d5-bfef-b3670478287f` — inline at `notification_service.dart:21`, mirroring the RevenueCat key style in `main.dart` |
| External id | The anonymous Firebase UID — same id Mixpanel is identified with |
| Entitlement to push | None. Push is independent of subscription state |

---

## 2. The service

`NotificationService` — a GetIt **singleton** (`service_locator.dart:407`), depending on
`LogEventUsecase`, `UserAnalyticsService` and `SharedPreferences`.

> ⚠️ **The dependency direction is load-bearing.** `NotificationService` depends on
> `UserAnalyticsService`, which is why OneSignal tag writes live in `NotificationService`
> and **never** inside `UserAnalyticsService` — the reverse edge would be a construction
> cycle. `UserAnalyticsService` would otherwise be the natural home, since it already
> fires at exactly the same checkpoints.

| Method | What it does | Called from |
|---|---|---|
| `initialize()` | `OneSignal.initialize(appId)`. Idempotent. **Deliberately does not prompt** | `main.dart:56`, once at boot after Firebase |
| `requestPermission()` | `OneSignal.Notifications.requestPermission(true)`; logs `Notifications Opted In`/`Opted Out` and sets the `notifications_enabled` People property | `reminders_screen.dart:48` |
| `login(uid)` | `OneSignal.login(uid)` — attaches the external id | `splash_bloc.dart` `_ensureSignedIn`, beside `identify(uid)` |
| `logout()` | Detaches it. Unused while auth is anonymous-only | — |
| `setTags(map)` | `OneSignal.User.addTags`. Fire-and-forget | The funnel checkpoints in §5 |
| `setFunnelStage(stage)` | Monotonic `funnel_stage` write | ditto |
| `setSubscriber(bool, {isTrial})` | `is_subscriber`, and `is_trial` when the entitlement was read | Paywall success, splash gate |
| `setLastActive()` | `last_active_at`, date-only | `splash_bloc.dart` every launch |
| `setLastScan()` | `last_scan_at`, date-only | `home_bloc.dart` on every successful scan, food or litter |

All of them no-op off iOS or before `initialize()`, and swallow errors with a
`debugPrint` — **tagging must never be able to break a user flow.**

---

## 3. Who can actually be reached

This is the single most important thing to understand before building a campaign.

Permission is requested at the onboarding **`reminders`** screen, which is
`OnBoardingPhase` index **10 of 12**:

```
0 welcome   1 scanDemo   2 recipesArticles   3 proofChart   4 whyYucat   5 nutritionFact
6 profileIntro   7 profileName   8 rating   9 notifPrimer   10 reminders   11 healthIntro
```

(`notifPrimer` at index 9 is a **mock** — it requests nothing.)

So anyone who abandons in phases 0–9 has no push subscription and **cannot be messaged
at all**, regardless of what tags we wrote for them.

| Funnel | Reachable? |
|---|---|
| Onboarding phases 0–9 | ❌ No permission yet — tagged, but undeliverable |
| Onboarding phases 10–11 | ✅ If they granted at `reminders` |
| Cat creation (12 steps) | ✅ Runs after onboarding's PageView |
| Paywall | ✅ Runs last |

We tag every stage anyway: it costs nothing, it's useful on export, and it becomes
deliverable the moment permission moves earlier. But **don't build a campaign against
"dropped in onboarding" and expect reach.**

---

## 4. Identity

`login(uid)` runs in `SplashBloc._ensureSignedIn`, right after
`UserAnalyticsService.identify(uid)` — i.e. at boot, before onboarding, on every launch.

It **used to** run in `HomeBloc`. That was wrong for this purpose: Home is only reached
after onboarding, cat creation and the paywall all succeed, so every user who dropped out
stayed anonymous — exactly the population the tags exist to describe.

**Reinstall caveat.** If the Firebase UID is new (the usual case for a reinstall, since
auth is anonymous), the user is a fresh OneSignal identity with no tags. If it somehow
resolves to an existing external id, OneSignal *switches* to that user rather than merging,
so any tags written on the pre-login anonymous record are lost. Neither case loses data
that matters, but it means tag history is not guaranteed continuous across reinstalls.

---

## 5. Tag schema

Coarse on purpose — Mixpanel already answers "which exact screen" (see `docs/analytics.md`).
These tags exist to make **Segments** possible, not to duplicate the event funnel.

**OneSignal has no typed tags.** Every value is a string, and dashboard Segments compare
them as strings — hence `NotificationTags.boolValue()` rather than raw bools.

> ⚠️ **Six tags, exactly.** The **Free** plan allows 6 data tags (and, from 2026-10-01, caps
> mobile push at **1,000 MAU** — the app is already at ~1,060, so push stops then unless the
> org moves to Growth: $19/mo + $0.012/MAU, 10 tags, 5 Journeys). OneSignal does not document
> what happens to a seventh tag, so the app never writes one. Dropped on 2026-09-12 to fit:
> `onboarding_completed` (implied by `funnel_stage` reaching `paywall`), `has_cat`,
> `trial_started_at` (Mixpanel keeps it) and the three `reminder_*` toggles (the reminders
> screen is presentational again). Historical users may still carry the old keys.

| Tag | Values | Written when | Where |
|---|---|---|---|
| `funnel_stage` | `onboarding` → `cat_create` → `paywall` → `subscribed` | Furthest stage reached | see below |
| `paywall_seen` | `"true"` | `Paywall Shown` | `paywall_bloc.dart` |
| `is_subscriber` | `"true"` / `"false"` | Purchase/restore success **and every splash gate** | `paywall_bloc.dart`, `splash_bloc.dart` |
| `is_trial` | `"true"` / `"false"` | Purchase success, **and every splash gate** from the entitlement's period type — so it turns itself off when the trial converts or lapses | `paywall_bloc.dart`, `splash_bloc.dart` |
| `last_active_at` | `YYYY-MM-DD` | Every launch | `splash_bloc.dart` |
| `last_scan_at` | `YYYY-MM-DD` | Every successful scan, food or litter | `home_bloc.dart` |

### The two Journeys these tags exist for

Both were built in the OneSignal dashboard on 2026-09-12 (Free plan: 3 Journeys allowed) —
nothing in the app schedules a notification. There is deliberately **no** "your trial ends
tomorrow" push, and no such promise on the paywall.

| Journey | Status | Enter (segment) | Steps | Exit |
|---|---|---|---|---|
| **Trial nudge** | **Live** | `Trialists`: `is_trial = "true"` | Wait 1 day → push template `Trial – scan more` ("Now try the treats and litter", EN + FR) | No longer matches the segment — the app refreshes `is_trial` from the entitlement on every launch, so conversion, lapse and cancellation all end it. Re-entry: once |
| **Dropped at paywall** | **Draft — do not set live before the build with the returning-user offer ships**, then add an *App Version ≥ that build* filter to the segment | `Dropped at paywall`: `funnel_stage = "paywall"` AND `is_subscriber ≠ "true"` (171 push-reachable on creation; `paywall_seen` is redundant with the stage and kept only for the older Segments) | Wait 1 hour → push `Paywall drop – value` ("Your cat's profile is ready") → wait 1 day → push `Paywall drop – discount` ("Your first year for €19.99"), EN + FR, no countdowns | No longer matches the segment (`is_subscriber` flips to `"true"`). Re-entry: once. "Future additions only" is **off** so past droppers enter too |

The discount push is honest because the `returning_user` paywall gate presents the
second-chance sheet on its own (`source = auto`), so a tap on the push lands on the offer
without having to cancel a store sheet first — see the paywall README §1. The app has no
notification click handler, so a push simply opens the app; the splash gate does the rest.

### Four rules that keep the segments honest

1. **`funnel_stage` is monotonic.** `setFunnelStage` ignores any stage at or below the
   high-water mark, which is persisted in `SharedPreferences`
   (`onesignal_furthest_funnel_stage`) rather than held in memory, because the process
   dies between sessions. Without this, a subscriber re-entering onboarding — via the
   debug reset, or just the splash gate — would be demoted to `onboarding` and dropped
   into a win-back segment.

2. **`is_subscriber` is refreshed on every splash gate, not just on purchase.** A churned
   subscriber would otherwise keep `is_subscriber = "true"` for ever and never enter a
   win-back segment.

3. **`funnel_stage = paywall` does not mean the user got past the paywall.** It's written
   on `Paywall Shown`, before any purchase. (The old `onboarding_completed` tag said the
   same thing one step earlier and was dropped for the tag budget; the SharedPreferences
   key of that name still exists and is written even earlier, when the cat is created.)
   `is_subscriber` is what says they converted.

4. **`funnel_stage = cat_create` is only written in create mode, not edit mode.**
   `_trackStepView` fires for both; the tag is gated on `_originalCat == null`. Otherwise
   an established user tweaking a cat profile would land in "stalled mid-wizard".

### Not hooked to `Cat Creation Step Abandoned`

That event (`cat_create_bloc.dart:122`) sounds like the right signal and isn't — it fires
only on **backward** movement within the wizard, and a user who kills the app mid-wizard
fires nothing. Abandonment is captured structurally instead: `funnel_stage = cat_create`
written on step view, never advanced to `paywall`.

---

## 6. Segments

Build these under **Audience → Segments**. All comparisons are string comparisons.

| Segment | Filter |
|---|---|
| **Dropped at paywall** | `paywall_seen` = `true` AND `is_subscriber` ≠ `true` |
| **Dropped in cat wizard** | `funnel_stage` = `cat_create` (never advanced to `paywall`) |
| **Dropped in onboarding** | `funnel_stage` = `onboarding` — ⚠️ mostly unreachable, see §3 |
| **Churned subscriber** | `funnel_stage` = `subscribed` AND `is_subscriber` ≠ `true` |
| **Dormant** | any of the above AND `last_active_at` before *N* days ago |

Use `≠` rather than `= false`: a user who never reached that checkpoint has **no tag at
all**, and `= false` would exclude them.

---

## 7. Testing

There is no `test/` directory in this repo, so this is a device exercise.

**An iOS device is required.** Everything no-ops on simulator and on Android, so a
simulator run shows zero tags and proves nothing. `kDebugMode` sets `OSLogLevel.verbose`
(`notification_service.dart:40`), so SDK calls print to console.

Use Profile → **Reset test user** first (deleting the app is not enough — the Firebase
session survives in the Keychain, and with it the OneSignal external id). Then walk the
funnel, checking **Audience → Users** and finding yourself by external id (the Firebase
UID):

| Step | Expected |
|---|---|
| Mid-onboarding | `funnel_stage = onboarding`, `last_active_at` set |
| Grant at `reminders` | device becomes push-subscribed |
| Enter cat wizard, quit | `funnel_stage = cat_create` |
| Finish the cat | nothing new — the next tag lands at the paywall |
| Reach paywall, kill app | `funnel_stage = paywall`, `paywall_seen = true` |
| Subscribe (sandbox) | `funnel_stage = subscribed`, `is_subscriber = true` |

Then the two invariants:

- **Monotonic** — after subscribing, re-enter onboarding via `kTestBuildResetOnboarding`
  and confirm `funnel_stage` stays `subscribed`.
- **Churn** — with `is_subscriber = true`, force the splash gate to see no entitlement and
  confirm the tag flips to `false`.

Finally, build each segment in §6 and confirm the test user lands in exactly one.

---

## 8. Known gaps

| Gap | Detail |
|---|---|
| **No `OneSignalNotificationServiceExtension` target** | `ios/Runner.xcodeproj` has only `Runner` and `RunnerTests`, and the `Podfile` has no extension block. Consequence: **no confirmed-delivery stats, no rich media (images) in notifications, no `mutable-content` badge processing.** Doesn't block tags or segments, but caps what campaigns can do |
| **Dashboard/APNs config unverified** | `aps-environment` = `production` (`Runner.entitlements`) and `UIBackgroundModes` = `[remote-notification]` (`Info.plist:93-96`) are set. Whether the OneSignal dashboard app exists and the APNs `.p8` is uploaded **cannot be checked from the repo** — if it isn't, permission never resolves and no tag ever arrives |
| **Permission asked very late** | Phase 10 of 12 (§3). Moving it earlier would make most of the funnel reachable, but it changes onboarding conversion — a product decision wanting an A/B test, not a code edit |
| **Reminders screen is presentational** | Its three toggles are not stored anywhere (they cost 3 of the Free plan's 6 tags); "Monthly check-in" schedules nothing. Revisit on Growth |
| **Free-plan MAU cap from 2026-10-01** | Mobile push stops above 1,000 MAU on Free; the app is already over. Decide on Growth before then or accept losing push |
| **No Android push** | Nothing wired at all |
| **No click / foreground listeners** | `Notifications.addClickListener` and `addForegroundWillDisplayListener` are never registered, so a push cannot deep-link into a screen and there's no in-app handling of a notification arriving while the app is open |
| **No In-App Messages** | The SDK subspec is present but unused |
| **No tests** | `NotificationService` has no coverage; the monotonic guard in `setFunnelStage` is pure and cheap to test if a `test/` directory is ever added |
