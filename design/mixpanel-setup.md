# Mixpanel Setup — Step by Step (Revamp)

Click-by-click guide to stand up a clean Mixpanel project for the YuCat revamp and build a
proper dashboard. Event & property names are defined in **`design/analytics.md`** — keep that
open alongside this. You do the clicks (I can't log into your account).

> **Why a new project:** the legacy app is still live and writes to the old token
> (`a2e7bb0030da8c6a41153524b5051ea4`) using the same event names. A fresh project guarantees
> the revamp's funnels are never polluted by old-version traffic. Every revamp event also
> carries `tracking_version = v2` as a safety net.

UI labels below match Mixpanel as of 2026; if a menu moved, search the top bar — the nouns
(Funnels, Cohorts, Retention, Insights, Boards) are stable.

---

## §0 — Create the project, get the token, verify events

1. **Create the project.** Top-left **project switcher → "＋ New Project"** (or
   *Organization Settings → Projects → Create Project*). Name it e.g. `YuCat (v2)`.
   Pick data residency = **US** (matches your Firebase `us-central1`; only matters for EU data
   rules).
2. **Copy the Project Token.** Gear ⚙️ → **Project Settings → Access Keys → "Project Token"**.
   Copy that string and **paste it back to me** — I'll swap it into
   `lib/service_locator.dart:_mixpanelToken` (there's a `TODO(revamp)` marker there now). The
   app currently still points at the old token, so nothing breaks until we swap.
3. **Confirm identity mode.** Gear ⚙️ → **Project Settings → Identity Merge** → ensure
   **"ID Merge" is ON** (it's the default for new projects). This is what lets our
   `mixpanel.identify(<firebase_uid>)` call (in `HomeBloc`) fuse the anonymous device profile
   with the logged-in profile, so a user's pre- and post-identify events stay on one profile.
4. **Run the new build** (after I swap the token) on a device/simulator and use the app:
   launch → onboarding → paywall → (sandbox) subscribe → create a cat → scan.
5. **Verify in Live View.** Left nav → **Events** → toggle **"Live View"** (real-time stream).
   You should see, in *this* project:
   - `App Opened` with `launch_type = cold` and `tracking_version = v2`,
   - `Onboarding Started`, `Paywall Shown` (with `trigger`), etc.
   Click any event row → check the properties panel shows `tracking_version`, `$app_version_string`.
6. **Confirm no leakage.** Open the **old** project's Live View → the new build should send it
   **nothing** (only phones still running the legacy app appear there).

✅ Once events stream into the new project, you're ready to build reports.

---

## §1 — (Optional, recommended) Lexicon: register events & properties

Gear ⚙️ → **Lexicon**. This makes report-builder dropdowns show friendly names and lets you
hide noise (e.g. Mixpanel's auto `$ae_*` events).

- **Events tab → "＋"**: add the events you care about from `analytics.md §2` (at minimum:
  `App Opened`, the Onboarding set, `Cat Created`, `Product Image Captured`,
  `Product Detail Viewed`, `Paywall Shown`, `Plan Selected`, `Subscription Completed`,
  `Subscription Purchase Failed`). Give each a one-line description.
- **Profile Properties tab**: register the People properties from `analytics.md §1`
  (`is_subscriber`, `cats_count`, `total_scans`, `attribution_source`, …) with types.
- You can do this later — reports work without Lexicon — but it keeps the workspace clean.

---

## §2 — Funnels (the core "where do they drop" reports)

**Create New → Funnels** (all report types live under the purple **Create New** button, not a
"Reports" left-nav item). For each funnel below: click **"＋ Add Step"**
for each event in order, set the **conversion window** (top-right; start with **7 days** for
acquisition, **1 day** for in-session funnels), then **Save** (top-right) with the given name.

Tip: to **filter** a step, hover the step → **"＋ Filter"** → pick the property. To **break
down**, use the **"Breakdown"** control (top bar) → pick a property → applies to the whole funnel.

### A. Acquisition — install → paying  *(window: 30 days)*
```
1. App Opened        filter: launch_type = cold
2. Onboarding Started
3. Onboarding Completed
4. Paywall Shown     filter: trigger = onboarding_complete
5. Subscription Completed
```
Breakdown by **`attribution_source`** to see which channel converts. The
`Onboarding Completed → Paywall Shown → Subscription Completed` legs are where you'll see the
biggest drop. Save as **"A · Acquisition"**.

### B. Returning-user gate  *(window: 7 days)*
```
1. App Opened        (no filter, or launch_type = warm)
2. Paywall Shown     filter: trigger = returning_user
3. Subscription Completed   ── then add an OR step: Subscription Restored
```
For step 3, click the step's event → **"＋"** to add `Subscription Restored` as an alternative
("any of"). Save as **"B · Returning-user gate"**.

### C. Purchase micro-funnel  *(window: 1 hour)*
```
1. Paywall Shown
2. Plan Selected        (optional middle step)
3. Subscription Completed
```
Add a **breakdown by `trigger`** to compare onboarding vs returning conversion. To quantify
Apple-sheet abandonment, build a sibling Insights report on `Subscription Purchase Failed`
broken down by `reason` (see §5). Save as **"C · Purchase"**.

### D. Activation — subscriber → first value  *(window: 7 days)*
```
1. Subscription Completed
2. Cat Created
3. Product Image Captured
4. Product Detail Viewed
```
Save as **"D · Activation"**.

### E. Scan success  *(window: 1 hour)*
```
1. Product Image Captured
2. Product Detail Viewed
```
To see the failure rate, add a second Insights metric counting `Product Image Scan Failed`
÷ `Product Image Captured` (§5). Save as **"E · Scan success"**.

### F. Cat-create wizard — flow & drop-off
Built on the dedicated **`Cat Wizard Step Viewed`** event (fires once per step with `step_index`,
`step_name`, `is_edit_mode`). The 12 steps in order: `CatName, Gender, ProfilePhoto, Age,
BodyCondition, Activity, WaterIntakeFact, NeuteredStatus, Coat, CoatFact, HealthConditions,
Breed` (WaterIntakeFact & CoatFact are "did-you-know" interstitials).

**Always add the filter `is_edit_mode` = `false`** so you measure first-time creation, not people
re-editing an existing cat (who jump to arbitrary steps and would pollute the curve).

- **Drop-off curve (fastest):** Insights → event `Cat Wizard Step Viewed`, filter
  `is_edit_mode = false`, measure **Unique users**, **Breakdown → `step_name`**, sort by
  `step_index`. The cliff between two bars is your friction point. Save as **"Cat wizard drop-off"**.
- **Strict funnel:** Funnels → `Cat Wizard Step Viewed` × 12, each step filtered to its
  `step_name` in order (all with `is_edit_mode = false`), window 1 hour. Save as **"F · Cat wizard"**.
- **Flows:** Create New → Flows, starting event `Cat Wizard Step Viewed` — auto-visualizes the path.

> `Cat Creation Step Completed` / `Step Abandoned` still exist for forward/back transitions, but
> `Cat Wizard Step Viewed` is the clean basis for the flow funnel.

### Onboarding flow & drop-off — which screen, where they leave

Built on the dedicated **`Onboarding Step Viewed`** event (fires once per onboarding screen with
`step_index` 0–11 and a normalized `step_name`: `welcome, scanDemo, attribution, proofChart,
whyYucat, nutritionFact, profileIntro, profileName, rating, notifPrimer, reminders,
healthIntro`). Three complementary views — start with the first:

- **Drop-off curve (fastest read):** Create New → **Insights** → event `Onboarding Step Viewed`,
  measure **Unique users**, **Breakdown → `step_name`**. Sort the bars by `step_index` (ascending).
  Each bar = how many users *reached* that screen; the cliff between two adjacent bars is exactly
  where people leave. Save as **"Onboarding drop-off"**.
- **Strict funnel:** Create New → **Funnels** → add `Onboarding Step Viewed` as **every** step
  (12 total), each with a **step filter `step_name` = the screen for that position**, in order
  (welcome → … → healthIntro). Window 1 day. Gives exact step-to-step conversion %.
  Save as **"F2 · Onboarding flow"**.
- **Flows (auto-path, no setup):** Create New → **Flows** → set the starting event to
  `Onboarding Step Viewed`. Mixpanel draws the real paths users take between screens, including
  where they exit the app — the quickest way to *see* the full flow without building steps.

> Use `Onboarding Step Viewed` (not the generic `Screen View`) for onboarding analysis: it's
> scoped to onboarding, ordered by `step_index`, and has no name gaps.

---

## §3 — Cohorts (segments to slice every report)

Left nav → **Users → Cohorts → "＋ Create Cohort"**. Define by profile property, **Save**,
then in any report use the **filter → "Cohort"** to scope it.

| Cohort | Definition |
|---|---|
| **Subscribers** | `is_subscriber` = true |
| **Activated** | `has_cat` = true **AND** `total_scans` ≥ 1 |
| **Power users** | `total_scans` ≥ 10 |
| **Stalled (onboarded, not paying)** | `onboarding_completed` = true **AND** `is_subscriber` = false |
| **By channel** | one cohort per `attribution_source` value, or just break funnels down by it |

Use **Stalled** as a remarketing audience and as a funnel filter to study why they didn't convert.

---

## §4 — Retention

**Create New → Retention**.

- **App retention:** Born event = **`App Opened`**, Returning event = **`App Opened`**,
  granularity **Weekly**. Add cohort filter **Subscribers** to compare paid vs all.
- **Scan retention (habit):** Born = `App Opened`, Returning = **`Product Image Captured`** —
  shows whether users keep scanning, the core habit. Save both.

---

## §5 — Insights / key metrics

**Create New → Insights**. Each is one saved metric:

- **DAU / WAU** — Event `App Opened`, measured as **Unique users**, line chart, daily/weekly.
- **Onboarding→Subscribe conversion %** — quickest via Funnel A's overall conversion number;
  pin that number.
- **Purchase failure reasons** — Event `Subscription Purchase Failed`, **Breakdown: `reason`**
  (`cancelled` / `platform_error` / `not_active` / `unknown`), bar chart. `cancelled` = users
  who opened the Apple sheet then backed out.
- **Scan failure rate** — formula metric: `Product Image Scan Failed` ÷ `Product Image Captured`
  (use the **"＋ Add formula"** / metric-ratio option), as a %.
- **Avg scans per user** — Event `Product Image Captured`, measured as **Average per user**.
- **Promo-toggle lift** — Funnel C conversion, **Breakdown: did `Paywall Promo Toggled` fire** —
  or compare two saved copies of Funnel C, one filtered to users who fired
  `Paywall Promo Toggled` with `promo_on = true`.

---

## §6 — Board (the dashboard) + alerts

1. Left nav → **Boards → "＋ New Board"**, name it **"YuCat v2 — Product"**.
2. On each saved report, use **"Add to Board"** (or from the Board, **"＋ Add" → existing report**).
   Suggested layout, three rows:
   - **Acquisition:** Funnel A, DAU/WAU, Onboarding→Subscribe %.
   - **Activation:** Funnel D, Funnel E, Scan retention, Avg scans/user.
   - **Monetization:** Funnel C, Purchase failure reasons, Funnel B, Subscribers count.
3. Add a **date control** at the top of the Board (Board settings) so all tiles share a range.
4. **Alert (optional):** open the Funnel A or conversion metric → **"⋯" → Set Alert** → notify
   on a significant drop (e.g. weekly conversion down >20%). Route to email/Slack.

---

## Done / hand-back checklist

- [ ] New project created; **Project Token pasted to me** for the code swap.
- [ ] Identity Merge = ID Merge confirmed.
- [ ] New build verified in Live View (events + `tracking_version=v2`); old project quiet.
- [ ] Funnels A–F saved.
- [ ] Cohorts created.
- [ ] Board assembled.

When you paste the token I'll swap it, run `flutter analyze`, and you can ship.
