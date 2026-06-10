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
> See **`design/mixpanel-setup.md`** for the step-by-step project + dashboard setup.

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
| `total_scans` | int (incremented +1 per scan) | HomeBloc scan success |
| `current_streak` | int | HomeBloc scan success |
| `last_scan_at` | ISO8601 string | HomeBloc scan success |
| `attribution_source` | string | onboarding attribution step |
| `onboarding_completed` | bool | onboarding finalized |
| `onboarding_completed_at` | ISO8601 string | onboarding finalized |
| `notifications_enabled` | bool | reminders permission prompt |

**Suggested cohorts:** Subscribers (`is_subscriber = true`), Activated (`has_cat = true` AND
`total_scans ≥ 1`), Power users (`total_scans ≥ 10`), By channel (`attribution_source`),
Stalled (`onboarding_completed = true` AND `is_subscriber = false`).

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
| `Streak Milestone` | `streak_days` |

### Paywall & subscription
| Event | Properties | Notes |
|---|---|---|
| `Paywall Shown` | `trigger`, `offering`, `intro_eligible`, `timestamp` | `trigger` now `onboarding_complete` / `returning_user` / `manual` (was always `manual`); `intro_eligible` **NEW** |
| `Plan Selected` | `package_id`, `package_type`, `trigger`, `timestamp` | **NEW** — fires when the user switches the highlighted plan |
| `Paywall Promo Toggled` | `promo_on`, `trigger`, `timestamp` | **NEW** — limited-time intro-offer switch |
| `Subscription Completed` | `package_id`, `package_type`, `price`, `currency`, `trigger`, `timestamp` | |
| `Subscription Restored` | `trigger`, `timestamp` | |
| `Subscription Purchase Failed` | `reason` (`cancelled`/`platform_error`/`not_active`/`unknown`), `error_message?`, `package_type`, `trigger` | **NEW** — `cancelled` = user backed out of the Apple sheet |
| `Subscription Restore Failed` | `reason` (`no_active_subscription`/`error`), `error_message?` | **NEW** |
| `Paywall Dismissed` | `time_viewed_seconds`, `cta_tapped`, `timestamp` | |

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
  → Plan Selected (optional)
  → Subscription Completed
```
Use `Subscription Purchase Failed` (`reason = cancelled`) as a conversion-loss segment to
quantify Apple-sheet abandonment. Compare conversion with vs. without `Paywall Promo Toggled`.

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
