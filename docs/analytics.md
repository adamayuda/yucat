# Analytics & Mixpanel Reference

This is the source of truth for what YuCat tracks and how to turn it into funnels &
cohorts in the **Mixpanel** dashboard. Analytics is Mixpanel-primary (Firebase Analytics
infra exists but is unused). Events flow `LogEventUsecase → AnalyticsRepository →
mixpanel.track(...)`. People properties flow through `UserAnalyticsService →
SetUserPropertiesUsecase → mixpanel.getPeople().set/increment(...)`, bound to the
anonymous Firebase UID via `mixpanel.identify(uid)` — called at boot in `SplashBloc`
(`splash_bloc.dart`, right after anonymous sign-in), with `HomeBloc` making a second,
idempotent call. `UserAnalyticsService._identified` is the per-session guard.

**Every event name lives in `lib/features/analytics/analytics_events.dart`, and every call
site uses a constant.** There are no inline event-name literals left in `lib/`; keep it that
way. A literal is how a typo ships silently — the event simply appears in Mixpanel under a
new name and no report ever picks it up. People-property names live in `UserProps` in the
same file.

**Firebase Analytics sends no custom events.** The orphaned `AnalyticsFirebaseDataSource`
— registered in DI, injected nowhere, called never — has been deleted. The
`firebase_analytics` package stays in `pubspec.yaml` on purpose: the SDK auto-collects
`first_open`, `session_start`, `screen_view` and `in_app_purchase` with no Dart code, and
that stream is what feeds the Firebase console, Play Console and Google Ads install
attribution. Dropping the package would silently kill attribution the moment paid
acquisition starts. Purchase events reach Google Ads through RevenueCat's own Firebase
integration, so there is no reason to dual-send from the app.

> **Revamp uses a separate Mixpanel project.** The relaunch writes to its own Mixpanel
> project/token (swapped in `service_locator.dart:_mixpanelToken`) so its data never overlaps
> with the legacy app, which keeps the old token. Every revamp event is also stamped with the
> super property **`tracking_version = v2`** (set in `_registerMixpanel`). Build/version
> segmentation comes free from the SDK's auto `$app_version_string` / `$app_build_number`.
> See **`docs/mixpanel-setup.md`** for the step-by-step project + dashboard setup.

---

## 1. People properties (set up these profile properties in Mixpanel)

Set on the user's People profile (keyed by Firebase UID). Use these to **segment any funnel**.

| Property | Type | Set where |
|---|---|---|
| `platform` | string (`ios`/`android`) | on identify (SplashBloc at boot) |
| `is_subscriber` | bool | paywall purchase/restore; splash gate on every cold launch |
| `subscription_plan` | string (`weekly`/`annual`) | paywall purchase |
| `subscription_price` / `subscription_currency` | number / string | paywall purchase |
| `cats_count` | int | HomeBloc after cats load (authoritative) |
| `has_cat` | bool | derived from `cats_count > 0` |
| `primary_cat_age_group` | string | HomeBloc |
| `primary_cat_breed` | string | HomeBloc — `cat_product_assessment.dart` carries ~25 breed rules; this is how you learn whether real users own breeds those rules name or ones that fall through to the archetypes |
| `$created` | ISO8601 string | on identify, **`setOnce`** — the only set-once property. A plain set would reset first-seen on every cold start and make cohort ageing meaningless |
| `language` | string (one of the 6 shipped locales) | app `builder` once the locale resolves — the locale the app actually *resolved to*, so an unsupported device language correctly reads `en` |
| `country` | string (e.g. `ES`) | same place, from the device locale. Separate from `language`: a Spanish speaker in the US is a different market from one in Spain |
| `last_active_at` | ISO8601 string | on identify, every boot. Recency previously existed only as a OneSignal tag, so Mixpanel could not segment dormant users at all |
| `total_sessions` | int (incremented +1 per identify) | on identify — the companion to `total_scans` for engagement depth |
| `total_scans` | int (incremented +1 per scan) | HomeBloc scan success — **food and litter both count** |
| `last_scan_at` | ISO8601 string | HomeBloc scan success |
| `attribution_source` | string | ⚠️ **no longer written** — the onboarding attribution step was replaced by `recipesArticles` (parked, not deleted). Historical values remain |
| `onboarding_completed` | bool | onboarding finalized |
| `onboarding_completed_at` | ISO8601 string | onboarding finalized |
| `notifications_enabled` | bool | reminders permission prompt |

**Suggested cohorts:** Subscribers (`is_subscriber = true`), Activated (`has_cat = true` AND
`total_scans ≥ 1`), Power users (`total_scans ≥ 10`), By channel (`attribution_source` — ⚠️ historical users only),
Stalled (`onboarding_completed = true` AND `is_subscriber = false`).

> **These are mirrored, in part, to OneSignal.** A coarse subset — `funnel_stage`,
> `onboarding_completed`, `has_cat`, `paywall_seen`, `is_subscriber`, `last_active_at` — is
> written as OneSignal **tags** at the same checkpoints, so drop-off audiences can be
> pushed to. The two systems are written side by side in the same functions and must be
> kept in step. Note the OneSignal copies are **strings**, not typed, and `funnel_stage` is
> monotonic where Mixpanel's equivalents are not. Schema and Segments:
> **`docs/onesignal.md`**.

---

## 2. Event catalog

### Session / lifecycle
| Event | Properties | Notes |
|---|---|---|
| `App Opened` | `launch_type` (`cold`/`warm`), `is_first_launch`, `platform`, `timestamp` | Entry node for every funnel; `warm` = resume from background. ⚠️ Fires from `main.dart`'s `initState` and does **not** await `SplashBloc`, so it can land on the pre-identify device id — whether it stitches depends on the project's ID Merge setting. |
| `App Backgrounded` | `session_seconds`, `screens_viewed` | Session end. `screens_viewed` is counted on `LogScreenViewUsecase` rather than in the route observer, because `bottom_nav_bar.dart` and `home_page.dart` also emit screen views by hand for tab changes, which push no route. Reset on every `App Opened`. |
| `App Error` | `error_type`, `error_message` (truncated to 500 chars), `context`, `silent` | Every uncaught Dart error, from the `FlutterError.onError` + `PlatformDispatcher.onError` handlers installed at the top of `main()`. ⚠️ Dart only — a **native** crash needs a crash-reporting SDK, which the app does not have. `silent = true` marks framework errors that are noisy but not actionable; filter them out first. |
| `Auth Sign In Failed` | `stage` | Anonymous sign-in produced no session at boot. Upstream cause of the cat-create crash — every uid-dependent write downstream is degraded when this fires. |

### Onboarding
| Event | Properties |
|---|---|
| `Onboarding Started` | `source`, `timestamp` |
| `Onboarding Get Started Tapped` | `timestamp` |
| `Onboarding Step Viewed` | `step_index` (0–11), `step_name`, `step_id`, `timestamp` — fires once per onboarding screen; use this (not `Screen View`) for the onboarding-flow funnel & drop-off. ⚠️ **Break down by `step_name` or `step_id`, never `step_index`** — see the warning below |
| `Onboarding Attribution Selected` | `source`, `timestamp` — ⚠️ **unreachable**, the screen was replaced |
| `Onboarding Attribution Skipped` | `timestamp` — ⚠️ **unreachable**, same |
| `Onboarding Step Back` | `from_phase`, `to_phase`, `timestamp` — **NEW**, backward drop-off marker |
| `Onboarding Completed` | `total_time_seconds`, `steps_viewed`, `attribution_source` (⚠️ now always null), `timestamp` |
| `Screen View` | `screen_name`, `index`, `name` — per onboarding phase |

**Onboarding scan** — a separate namespace from Home's scan, for the same user action.
Gated by RemoteConfig `onboarding_scan_enabled`; currently near-zero volume, so check the
flag before reading anything into these.

| Event | Properties |
|---|---|
| `Onboarding Scan Captured` | `timestamp` |
| `Onboarding Scan Succeeded` | `product`, `score`, `timestamp` — renamed from `Onboarding Scan Verdict`, which survives in the Lexicon with historical data only |
| `Onboarding Scan Failed` | `error_type` (`not_found`/`timeout`/`no_internet`/other), `error_message?`, `timestamp` |
| `Onboarding Scan Skipped` | `phase` (`error`/`intro`), `timestamp` |

⚠️ **`step_index` is a position, not an identity.** It is reused whenever a screen is
swapped: `attribution` held index 2 for 485 events before `recipesArticles` took the slot,
so every historical funnel keyed on index 2 mixes two unrelated screens. `step_id`
(`OnBoardingPhaseAnalytics.stepId`) is the stable, **append-only** alternative — a phase
keeps its id forever and a replacement takes the next free number, so `2` stays retired.
Use `step_name` or `step_id` as the funnel key and `step_index` only for ordering.

### Cat lifecycle
| Event | Key properties |
|---|---|
| `Cat Creation Started` / `Cat Edit Started` | `is_edit_mode`, `cat_name?` |
| `Cat Wizard Step Viewed` | `step_index`, `step_name`, `is_edit_mode`, `timestamp` — **NEW**, fires once per wizard step; use for the wizard flow funnel & drop-off (filter `is_edit_mode = false` for first-time creation) |
| `Cat Creation Step Completed` | `step_index`, `step_name`, `next_step_index`, `next_step_name` |
| `Cat Creation Step Abandoned` | `from_step(_name)`, `to_step(_name)` |
| `Cat Created` | `name`, `age_group`, `breed`, `gender`, `has_health_conditions`, `health_conditions`, `neutered`, `has_photo`, `creation_time_seconds`, `fields_completed`, `fields_skipped`, `completed_field_names` |
| `Cat Profile Updated` | `cat_name`, `cat_age_group`, `cat_breed`, `fields_changed` |
| `Cat Creation Failed` / `Cat Update Failed` | `error_type`, `error_message`, `step_index` |
| `Cat Profile Viewed` / `Edit Started` / `Deleted` / `Delete Failed` | `cat_*` ids / names |

### Health carnet
Per-cat veterinary records and the derived schedule. See
`lib/features/health_carnet/README.md` for the protocol catalogue behind `protocol_id`.

| Event | Key properties |
|---|---|
| `Health Carnet Viewed` | `record_count`, `due_count`, `urgent_count`, `has_weight_history`, `cat_age_group` |
| `Health Carnet Tab Changed` | `tab_index`, `tab_name` (`upcoming` / `history` / `calendar`) |
| `Health Task Completed` | `protocol_id`, `obligation`, **`was_overdue`**, `urgency`, `days_until` |
| `Health Task Snoozed` | `protocol_id`, `snooze_days`, `was_overdue` |
| `Health Record Added` | `protocol_id` (or `freeform`), `category`, `has_notes`, `has_weight`, `has_vet` |
| `Health Record Deleted` | `timestamp` |
| `Health Allergies Updated` | `allergen_count`, `allergens` — the declared list drives product-scan flags and recipe hiding, so this is the adoption signal for both |
| `Health Carnet Load Failed` | `error_message` |

⚠️ **`Health Task Completed` is only meaningful broken down by `protocol_id` and
`was_overdue`.** A completion count on its own says nothing: the question the feature
exists to answer is whether surfacing an act got it done *on time*. `was_overdue = false`
is the win. Note `urgency = to_schedule` marks a first-ever record for that protocol —
those are carnet backfill, not the app catching a deadline, and should be excluded from
any on-time rate.

### Product & search
| Event | Key properties |
|---|---|
| `Camera Access Result` | `granted`, `error_code` (`no_camera`, or the plugin's `CameraAccess*` code) |
| `Scan Cancelled` | `camera_ready`, `camera_error` |
| `Product Image Captured` | `mime_type` |
| `Product Image Scan Failed` | `error_type` (`not_found`/`error`), `error_message?`, `duration_ms` |
| `Product Selected` | `product_name`, `product_brand`, `source` (`image`/`search`), `duration_ms` (image scans only) |
| `Product Searched` | `query`, `query_length`, `results_count` |
| `Search Results Viewed` | `query`, `results_count`, `has_results` |
| `Product Detail Viewed` | `product_name`, `product_brand` |
| `Product Saved` / `Product Unsaved` | `product_name`, `product_brand` |

### Cat litter
| Event | Key properties |
|---|---|
| `Litter Selected` | `litter_name`, `litter_brand`, `litter_material`, `source` (`image`), `duration_ms` |
| `Litter Detail Viewed` | `litter_name`, `litter_brand`, `litter_material` |
| `Litter Saved` / `Litter Unsaved` | `litter_name`, `litter_brand` |

### Content discovery
| Event | Key properties |
|---|---|
| `Recipe Selected` | `recipe_id`, `recipe_name`, `category`, `difficulty`, `prep_minutes`, `source` |
| `Article Selected` | `article_id`, `article_title`, `category`, `read_minutes`, `source` |
| `Food Guide Item Selected` | `item_id`, `item_name`, `safety`, `source` |
| `Recipes Searched` / `Articles Searched` | `query`, `query_length`, `results_count` |
| `Recipes Filtered` / `Articles Filtered` | `category` (`"all"` for the All chip), `results_count` |
| `Content See All Tapped` | `section` (`recipes` / `articles` / `food_guide`) |
| `Content Lane Viewed` | `section`, `item_count` |
| `Article Read` | `article_id`, `article_title`, `category`, `read_minutes`, `seconds`, `scroll_pct`, `paragraphs` |

`source` values come from `ContentSource`: `home_lane`, `home_news_card`, `recipes_tab`,
`articles_list`, `food_guide_list` — the news card and the articles lane are separated
because they open the same route from different surfaces.

⚠️ **There is no `… Detail Viewed` event for these three.** The detail pages are bloc-free,
`AnalyticsRouteObserver` already emits `Screen View` for their routes, and every path into
them is one of the `… Selected` taps above, so the two would be 1:1. Add one if the app gains
deep links into a detail screen.

`Content Lane Viewed` fires **once per load, per lane, and only when the lane renders at
least one item** — the four Home sections each hide themselves entirely on an error or empty
catalogue, so a lane that never appeared correctly contributes nothing. This is the honest
denominator for lane conversion; `Screen View (HomeRoute)` over-counts. The guard is a
`_loggedItemCount` field in each section widget, not a bloc hook: `ArticlesBloc` is
constructed three times concurrently on Home and `RecipesBloc` / `FoodGuideBloc` twice each,
so a bloc-level hook would fire two or three times for one page load.

`Article Read` is emitted on **dispose** of `ArticleDetailRoute`, which is the only reason
that screen is a `StatefulWidget` — none of the measured state reaches its build output.
`scroll_pct` is the furthest point reached (it never decreases when the user scrolls back
up), and an article short enough to fit the viewport reports **100**, resolved by a
post-frame check rather than left at 0 where it would be indistinguishable from a bounce.
Compare `seconds` against the article's own claimed `read_minutes` to see whether the
editorial estimates are honest, and `scroll_pct` against `paragraphs` to control for length.

⚠️ **Emitted from the widget layer, never the blocs.** `ArticlesBloc` is constructed three
times concurrently (Home's news card, Home's articles lane, `ArticlesPage`) and
`RecipesBloc` / `FoodGuideBloc` twice each — a bloc-level hook fires two or three times per
user action. The search events are debounced 800 ms in the page (`EasyDebounce`) because the
list blocs filter in memory with no debounce; the filter events are logged from a
`BlocListener` so `results_count` reflects the state *after* the change.

The scan funnel now has its **edges**: `Camera Access Result` resolves once per scanner
open (so a user whose permission is denied is no longer invisible upstream of the shutter),
`Scan Cancelled` fires on dispose when no photo was taken, and every scan *outcome* —
`Product Selected`, `Litter Selected`, both `Product Image Scan Failed` branches — carries
`duration_ms`. The backend fans out to four parallel sources plus web search, and
`deadline-exceeded` is already a classified error type, so watch the duration distribution
creep toward the timeout rather than waiting for the failure rate to move.

⚠️ **The capture and failure events are shared with food.** The camera is a single entry
point — the backend decides whether the photo was food or litter — so
`Product Image Captured` and `Product Image Scan Failed` fire for **both** categories and
only the outcome events split. A scan funnel built on the capture event therefore counts
litter scans too; segment on the outcome event to separate them.

> **Removed:** `Streak Milestone` and the `current_streak` People property. The daily scan
> streak was never rendered anywhere in the app, so the two signals measured a feature
> users could not see. `total_scans` and `last_scan_at` remain.

### Paywall & subscription
| Event | Properties | Notes |
|---|---|---|
| `Paywall Shown` | `trigger`, `offering`, `trial_eligible`, `trial_days`, `timestamp` | `trigger` is `onboarding_complete` / `returning_user` / `manual` (no live call site passes `manual` — seeing it means a new entry point forgot to pass a trigger) |
| `Paywall CTA Tapped` | `package_id`, `package_type`, `price`, `currency`, `trigger`, `is_trial`, `trial_days`, `timestamp` | **NEW** — fires *before* the store sheet opens, so a sheet that never presents or never resolves is still counted. Same property set as `Subscription Completed` so the funnel segments identically |
| `Paywall Restore Tapped` | `trigger`, `timestamp` | **NEW** — fires before `Purchases.restorePurchases()` |
| `Plan Selected` | `package_id`, `package_type`, `trigger`, `timestamp` | Fires when the user switches the highlighted plan — *currently unreachable*: the paywall shows a single annual plan and no plan-picker widget is rendered |
| `Subscription Completed` | `package_id`, `package_type`, `price`, `currency`, `trigger`, `is_trial`, `trial_days`, `timestamp` | `is_trial: true` means **no money moved today** — revenue reporting must exclude these |
| `Subscription Restored` | `trigger`, `timestamp` | Carries no package/price/currency, unlike `Subscription Completed` |
| `Subscription Purchase Failed` | `reason` (`platform_error`/`not_active`/`unknown`), `error_code` (RevenueCat), `error_message?`, `package_type`, `trigger`, `timestamp` | Genuine store errors only. `error_code` is what separates a payment decline from a network drop from a store misconfiguration — `reason` alone cannot |
| `Paywall Purchase Cancelled` | `package_type`, `trigger`, `timestamp` | The user backed out of the store sheet. Split out of `Subscription Purchase Failed`, where it was ~6x the volume of real errors and made the event unreadable. ⚠️ Historical `Subscription Purchase Failed` rows with `reason = cancelled` predate the split |
| `Subscription Restore Failed` | `reason` (`error`), `error_message?`, `timestamp` | Genuine store errors only |
| `Paywall Restore Completed` | `restored` (bool), `trigger`, `timestamp` | Restore ran and found nothing. Split out of `Subscription Restore Failed`, which was **100%** `no_active_subscription` — the expected outcome for a first-time user, and pure noise on an error dashboard |
| `Paywall Dismissed` | `time_viewed_seconds`, `cta_tapped`, `timestamp` | Means **closed without converting**. It does not fire on purchase/restore success. `cta_tapped` now means "reached the store sheet during this paywall session, then left anyway" — it was hardcoded `false`, which made the property inert. True is the more interesting group and should track `Paywall Purchase Cancelled` closely |

### Other
| Event | Properties |
|---|---|
| `Profile Cat Tapped` | `cat_id`, `timestamp` |
| `Scan History Viewed` | `timestamp` |
| `Notifications Opted In` / `Opted Out` | `source` |
| `Review Prompt Requested` | `trigger` |
| `Free Limit Hit` | `limit_type`, `limit_value` — *currently not fired (hard paywall, no free tier)* |

---

## 3. Funnels to build in Mixpanel

Build these as **Funnels** (Reports → Funnels). Segment each by the People properties above
(e.g. break down by `platform`; `attribution_source` only splits historical users).

**A. Acquisition (new install → paying)**
```
App Opened (launch_type = cold)
  → Onboarding Started
  → Onboarding Completed
  → Paywall Shown (trigger = onboarding_complete)
  → Subscription Completed
```
Watch the `Onboarding Completed → Paywall Shown → Subscription Completed` steps for the
biggest drops. Cross-reference `Onboarding Step Back` and per-phase `Screen View` to find
*which* onboarding beat loses people.

**B. Returning-user gate (lapsed / re-install → re-subscribe)**
```
App Opened (launch_type = warm OR cold)
  → Paywall Shown (trigger = returning_user)
  → Subscription Completed OR Subscription Restored
```

**C. Purchase micro-funnel (paywall interaction → conversion)**
```
Paywall Shown
  → Paywall CTA Tapped
  → Subscription Completed
```
The two steps answer different questions. `Shown → CTA Tapped` is whether the offer
persuades; `CTA Tapped → Completed` is store-sheet abandonment.

Break the second step down by outcome — the three are mutually exclusive and should
account for every tap:

- `Subscription Completed` — converted.
- `Subscription Purchase Failed` (`reason = cancelled`) — backed out of the sheet.
- `Subscription Purchase Failed` (`reason != cancelled`) — genuine errors.

Any residual gap is taps whose sheet never resolved at all (failed to present, hung, or
the app was killed mid-purchase). That population was invisible before `Paywall CTA
Tapped` existed.

Segment by `is_trial` to compare trial-eligible against ineligible users — they see a
materially different CTA and price line.

**D. Activation (subscriber → first value)**
```
Subscription Completed
  → Cat Created
  → Product Image Captured
  → Product Detail Viewed
```

**E. Scan success funnel**
```
Product Image Captured
  → Product Selected            (vs. Product Image Scan Failed — track as failure rate)
  → Product Detail Viewed
  → Product Saved
```

**F. Cat-create wizard step funnel**
Build from `Cat Creation Step Completed` broken down by `step_name` (CatName → Gender →
ProfilePhoto → Age → BodyCondition → Activity → … → Breed) to see which step sheds users.
`Cat Creation Step Abandoned` shows backward movement.

**G. Content discovery (Home lane → open → engage)**
```
Content Lane Viewed (section = recipes | articles | food_guide)
  → Recipe Selected | Article Selected | Food Guide Item Selected  (source = home_lane)
  → Article Read (scroll_pct, seconds)          [articles only]

Content Lane Viewed → Content See All Tapped → … Selected (source = <list>)
```
Run it twice, filtered on `source = home_lane` vs the list sources, to separate lane
conversion from list-screen browsing. Use **`Content Lane Viewed`** as the denominator, not
`Screen View (HomeRoute)` — the lane event only fires when the lane actually rendered, so a
lane that hid itself on a failed or empty Firestore read is excluded rather than counted as
an ignored impression. Break `Recipe Selected` down
by `category` to see which content earns the taps, and watch `Recipes Filtered` /
`Articles Filtered` for whether the category chips are used at all — if they aren't, the
strips are costing vertical space for nothing.

---

## 4. Session Replay

`mixpanel_flutter_session_replay` records screen captures alongside the events above, so any
funnel step can be opened as "what did this user actually do". Owned by
`lib/services/session_replay_service.dart`; the recording surface is
`MixpanelSessionReplayWidget` wrapped around the app in `main.dart`.

**It is a second, standalone SDK.** Pure Dart, with no bridge into `mixpanel_flutter`'s native
`track`, so nothing is shared for free. Two hooks make replays and events line up, and both are
load-bearing:

| Hook | Where | Breaks if removed |
|---|---|---|
| `sessionReplayService.identify(uid)` | `UserAnalyticsService.identify` | Replays file under the pre-sign-in anonymous id, on a different profile than the events |
| `$mp_replay_id` on every event | `AnalyticsRepositoryImpl._withReplayId` | No event links to its replay; only Mixpanel's server-side stitching (distinct id + timestamp) would associate them |

Identity has a race: `SplashBloc` identifies at boot and can beat the SDK's async
`initialize()`, so `SessionReplayService` buffers the uid in `_pendingDistinctId` and applies it
once the instance exists.

⚠️ **Boot order is load-bearing.** `start()` is awaited in `main()` before `runApp`.
`MixpanelSessionReplayWidget` renders its child bare while `instance` is null and wraps it in
three widgets once one arrives — a different widget type in the same slot, so Flutter unmounts
the whole app subtree and rebuilds it, closing every root bloc under live pages. Moving the call
back into `initState` (as Mixpanel's docs suggest) reintroduces
`Bad state: Cannot add new events after calling close` on the first tap after init resolves.

**When it records**

- Release builds only — `kReleaseMode || kTestBuildForceSessionReplay` (`lib/config/test_flags.dart`).
- AND `session_replay_enabled` is true in Remote Config, AND `session_replay_sample_percent > 0`.
- Recording is never started explicitly: the widget starts it when the app foregrounds, sampling
  at `session_replay_sample_percent`. It stops itself when the app loses focus.

**Masking** — `autoMaskedViews: {AutoMaskedView.image}`.

- Images are masked: cat photos, product images, scan captures.
- Text is deliberately **not** masked, so replays are readable.
- Text *input* (`TextField`, `TextFormField`, `CupertinoTextField`) is masked by the SDK
  unconditionally and cannot be unmasked — typed cat names are covered for free.
- ⚠️ A new surface that renders user-supplied text outside a text field needs an explicit
  `MixpanelMask` wrapper.

**Verifying it works** — a `$mp_session_record` checkpoint event appears in Mixpanel whenever a
capture begins. It does not count against the data allowance, and it is the documented proof
that replay initialised correctly. Then check that one of our own events carries
`$mp_replay_id`.

✅ **Verified end-to-end on 2026-08-30.** `$mp_replay_id` is present in the Lexicon and
appears on real events, all of them from build **2.1.0** — so both hooks in the table above
are working and the app-side wiring is correct. Coverage is still tiny (13 of 6,611 screen
views over 7 days) purely because 2.1.0 is barely distributed; re-check the ratio after the
release, where it should approach the `session_replay_sample_percent` value for the share of
traffic on a replay-capable build. A number far below that on a widely-distributed build
means one of the two hooks has regressed.

---

## 5. Data residency

Events go to **`api.mixpanel.com`** — Mixpanel's **US** ingestion endpoint. This is the SDK
default: `Mixpanel.init` in `service_locator.dart` is called without a `serverURL`, and
`setServerURL` is never called. Confirmed against live data — `$mp_api_endpoint` has exactly
one value across the whole project.

The project is provisioned as US-resident, so **the code and the project agree** — this is
not a misconfiguration. It is, however, a standing policy question rather than a settled one:
the user base is heavily European (France, Belgium, Switzerland, Spain, Italy, Netherlands,
Portugal, Germany, Luxembourg, Austria, Monaco, plus the French overseas territories), so
personal data from EU users is processed in the US. Moving to EU residency is **not** a code
change alone — it needs a new EU-resident Mixpanel project, and historical data does not
migrate. Decide before the dataset gets larger, not after.

---

## 6. Maintenance

- Add new event/property names to `lib/features/analytics/analytics_events.dart` and this doc.
- Keep `trigger` values in `PaywallTrigger` aligned with the funnel definitions above.
- People properties are only meaningful because `mixpanel.identify(uid)` runs at boot in
  `SplashBloc` (with `HomeBloc` as an idempotent second call); don't remove either.
- Session Replay is a **separate SDK** that shares nothing automatically — if you add a new
  path that identifies the user or tracks an event outside `AnalyticsRepositoryImpl`, mirror
  the two hooks in §4 or replays and events will drift apart.
- ⚠️ **The Mixpanel plan caps the project at 5 saved reports and blocks cohorts, saved metrics,
  experiments and feature flags entirely.** Budget report slots before designing a board, and
  use inline report filters where you would otherwise reach for a cohort. The five in use are
  listed on the boards themselves.
- **Native crashes are not reported.** `App Error` covers every uncaught *Dart* error; there
  is no Crashlytics or equivalent, so a native crash leaves no trace anywhere.
- Two console-only settings nothing in this repo controls: the project's **ID Merge mode**
  (which decides whether the pre-identify `App Opened` stitches to the user's profile) and the
  session-timeout definition behind `$session_start` / `$session_end`.
