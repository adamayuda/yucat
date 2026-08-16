# Analytics & Mixpanel Reference

This is the source of truth for what YuCat tracks and how to turn it into funnels &
cohorts in the **Mixpanel** dashboard. Analytics is Mixpanel-primary (Firebase Analytics
infra exists but is unused). Events flow `LogEventUsecase → AnalyticsRepository →
mixpanel.track(...)`. People properties flow through `UserAnalyticsService →
SetUserPropertiesUsecase → mixpanel.getPeople().set/increment(...)`, bound to the
anonymous Firebase UID via `mixpanel.identify(uid)` (called once per session in `HomeBloc`).

New event/property names introduced for the funnel review live in
`lib/features/analytics/analytics_events.dart`. Pre-existing events still use inline string
literals; the names below are authoritative regardless.

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
| `platform` | string (`ios`/`android`) | on identify (HomeBloc) |
| `is_subscriber` | bool | paywall purchase/restore; splash gate on every cold launch |
| `subscription_plan` | string (`weekly`/`annual`) | paywall purchase |
| `subscription_price` / `subscription_currency` | number / string | paywall purchase |
| `cats_count` | int | HomeBloc after cats load (authoritative) |
| `has_cat` | bool | derived from `cats_count > 0` |
| `primary_cat_age_group` | string | HomeBloc |
| `total_scans` | int (incremented +1 per scan) | HomeBloc scan success — **food and litter both count** |
| `last_scan_at` | ISO8601 string | HomeBloc scan success |
| `attribution_source` | string | onboarding attribution step |
| `onboarding_completed` | bool | onboarding finalized |
| `onboarding_completed_at` | ISO8601 string | onboarding finalized |
| `notifications_enabled` | bool | reminders permission prompt |

**Suggested cohorts:** Subscribers (`is_subscriber = true`), Activated (`has_cat = true` AND
`total_scans ≥ 1`), Power users (`total_scans ≥ 10`), By channel (`attribution_source`),
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
| `App Opened` | `launch_type` (`cold`/`warm`), `platform`, `timestamp` | **NEW.** Entry node for every funnel; `warm` = resume from background. |

### Onboarding
| Event | Properties |
|---|---|
| `Onboarding Started` | `source`, `timestamp` |
| `Onboarding Get Started Tapped` | `timestamp` |
| `Onboarding Step Viewed` | `step_index` (0–11), `step_name`, `timestamp` — **NEW**, fires once per onboarding screen; use this (not `Screen View`) for the onboarding-flow funnel & drop-off |
| `Onboarding Attribution Selected` | `source`, `timestamp` |
| `Onboarding Attribution Skipped` | `timestamp` |
| `Onboarding Step Back` | `from_phase`, `to_phase`, `timestamp` — **NEW**, backward drop-off marker |
| `Onboarding Completed` | `total_time_seconds`, `steps_viewed`, `attribution_source`, `timestamp` |
| `Screen View` | `screen_name`, `index`, `name` — per onboarding phase |

### Cat lifecycle
| Event | Key properties |
|---|---|
| `Cat Creation Started` / `Cat Edit Started` | `is_edit_mode`, `cat_name?` |
| `Cat Wizard Step Viewed` | `step_index`, `step_name`, `is_edit_mode`, `timestamp` — **NEW**, fires once per wizard step; use for the wizard flow funnel & drop-off (filter `is_edit_mode = false` for first-time creation) |
| `Cat Creation Step Completed` | `step_index`, `step_name`, `next_step_index`, `next_step_name` |
| `Cat Creation Step Abandoned` | `from_step(_name)`, `to_step(_name)` |
| `Cat Created` | `name`, `age_group`, `breed`, `gender`, `has_health_conditions`, `neutered`, `has_photo`, `creation_time_seconds` |
| `Cat Profile Updated` | `cat_name`, `cat_age_group`, `cat_breed`, `fields_changed` |
| `Cat Creation Failed` / `Cat Update Failed` | `error_type`, `error_message`, `step_index` |
| `Cat Profile Viewed` / `Edit Started` / `Deleted` / `Delete Failed` | `cat_*` ids / names |

### Product & search
| Event | Key properties |
|---|---|
| `Product Image Captured` | `mime_type` |
| `Product Image Scan Failed` | `error_type` (`not_found`/`error`), `error_message?` |
| `Product Selected` | `product_name`, `product_brand`, `source` (`image`/`search`) |
| `Product Searched` | `query`, `query_length`, `results_count` |
| `Search Results Viewed` | `query`, `results_count`, `has_results` |
| `Product Detail Viewed` | `product_name`, `product_brand` |
| `Product Saved` / `Product Unsaved` | `product_name`, `product_brand` |

### Cat litter
| Event | Key properties |
|---|---|
| `Litter Selected` | `litter_name`, `litter_brand`, `litter_material`, `source` (`image`) |
| `Litter Detail Viewed` | `litter_name`, `litter_brand`, `litter_material` |
| `Litter Saved` / `Litter Unsaved` | `litter_name`, `litter_brand` |

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
| `Subscription Purchase Failed` | `reason` (`cancelled`/`platform_error`/`not_active`/`unknown`), `error_message?`, `package_type`, `trigger`, `timestamp` | `cancelled` = user backed out of the store sheet. **Always filter it out of error-rate charts** — it is a normal outcome, not a failure |
| `Subscription Restore Failed` | `reason` (`no_active_subscription`/`error`), `error_message?`, `timestamp` | No `trigger` — restore failures can't be split by gate |
| `Paywall Dismissed` | `time_viewed_seconds`, `cta_tapped`, `timestamp` | Means **closed without converting**. It no longer fires on purchase/restore success, so `cta_tapped` is now always `false` (kept for schema stability) |

### Other
| Event | Properties |
|---|---|
| `Notifications Opted In` / `Opted Out` | `source` |
| `Review Prompt Requested` | `trigger` |
| `Free Limit Hit` | `limit_type`, `limit_value` — *currently not fired (hard paywall, no free tier)* |

---

## 3. Funnels to build in Mixpanel

Build these as **Funnels** (Reports → Funnels). Segment each by the People properties above
(e.g. break down by `attribution_source` or `platform`).

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

---

## 4. Maintenance

- Add new event/property names to `lib/features/analytics/analytics_events.dart` and this doc.
- Keep `trigger` values in `PaywallTrigger` aligned with the funnel definitions above.
- People properties are only meaningful because `mixpanel.identify(uid)` runs in `HomeBloc`;
  don't remove that call.
