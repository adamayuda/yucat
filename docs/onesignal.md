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
| `setSubscriber(bool)` | `is_subscriber` | Paywall success, splash gate |
| `setLastActive()` | `last_active_at`, date-only | `splash_bloc.dart` every launch |

All of them no-op off iOS or before `initialize()`, and swallow errors with a
`debugPrint` — **tagging must never be able to break a user flow.**

---

## 3. Who can actually be reached

This is the single most important thing to understand before building a campaign.

Permission is requested at the onboarding **`reminders`** screen, which is
`OnBoardingPhase` index **10 of 12**:

```
0 welcome   1 scanDemo   2 attribution   3 proofChart   4 whyYucat   5 nutritionFact
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

| Tag | Values | Written when | Where |
|---|---|---|---|
| `funnel_stage` | `onboarding` → `cat_create` → `paywall` → `subscribed` | Furthest stage reached | see below |
| `onboarding_completed` | `"true"` | `_onOnBoardingFinalizedEvent` | `onboarding_bloc.dart` |
| `has_cat` | `"true"` / `"false"` | Cat created; re-synced on every Home load | `cat_create_bloc.dart`, `home_bloc.dart` |
| `paywall_seen` | `"true"` | `Paywall Shown` | `paywall_bloc.dart` |
| `is_subscriber` | `"true"` / `"false"` | Purchase/restore success **and every splash gate** | `paywall_bloc.dart`, `splash_bloc.dart` |
| `last_active_at` | `YYYY-MM-DD` | Every launch | `splash_bloc.dart` |

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

3. **`onboarding_completed` does not mean the user got past the paywall.** It's tagged at
   `_onOnBoardingFinalizedEvent`, which runs *before* the paywall is pushed. (Confusingly,
   the `onboarding_completed` **SharedPreferences key** is written even earlier — at
   `onboarding_bloc.dart:248`, when the cat is created. Same name, two different moments,
   neither of which implies conversion.) `is_subscriber` is what says they converted.

4. **`funnel_stage = cat_create` is only written in create mode, not edit mode.**
   `_trackStepView` fires for both; the tag is gated on `_originalCat == null`. Otherwise
   an established user tweaking a cat profile would land in "stalled mid-wizard".

### Not hooked to `Cat Creation Step Abandoned`

That event (`cat_create_bloc.dart:122`) sounds like the right signal and isn't — it fires
only on **backward** movement within the wizard, and a user who kills the app mid-wizard
fires nothing. Abandonment is captured structurally instead: `funnel_stage = cat_create`
written on step view, never followed by `has_cat = true`.

---

## 6. Segments

Build these under **Audience → Segments**. All comparisons are string comparisons.

| Segment | Filter |
|---|---|
| **Dropped at paywall** | `paywall_seen` = `true` AND `is_subscriber` ≠ `true` |
| **Dropped in cat wizard** | `funnel_stage` = `cat_create` AND `has_cat` ≠ `true` |
| **Dropped in onboarding** | `funnel_stage` = `onboarding` AND `onboarding_completed` ≠ `true` — ⚠️ mostly unreachable, see §3 |
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

Delete the app first — that clears both `onboarding_completed` and the funnel-stage
high-water mark. Then walk the funnel, checking **Audience → Users** and finding yourself
by external id (the Firebase UID):

| Step | Expected |
|---|---|
| Mid-onboarding | `funnel_stage = onboarding`, `last_active_at` set |
| Grant at `reminders` | device becomes push-subscribed |
| Enter cat wizard, quit | `funnel_stage = cat_create`, no `has_cat` |
| Finish the cat | `has_cat = true`, `onboarding_completed = true` |
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
| **Reminder-type selections are not persisted** | The `reminders` screen lets the user pick reminder kinds; nothing is stored and **no local notifications are ever scheduled**. The screen's only real effect is the permission prompt |
| **No Android push** | Nothing wired at all |
| **No click / foreground listeners** | `Notifications.addClickListener` and `addForegroundWillDisplayListener` are never registered, so a push cannot deep-link into a screen and there's no in-app handling of a notification arriving while the app is open |
| **No In-App Messages** | The SDK subspec is present but unused |
| **No tests** | `NotificationService` has no coverage; the monotonic guard in `setFunnelStage` is pure and cheap to test if a `test/` directory is ever added |
