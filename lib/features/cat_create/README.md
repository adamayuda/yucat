# Cat-create wizard

The 12-step profile wizard, used in two contexts (first-run onboarding and standalone
create/edit) with one set of step widgets.

This is the source of truth for the step order and everything coupled to it. It deliberately
does **not** describe individual step widgets — the code makes those obvious.

---

## 1. The 12 steps

The canonical list is `_stepNames` in `bloc/cat_create_bloc.dart:21`. **10 input steps + 2
non-input "did you know" interstitials.**

| # | Step | | # | Step |
|---|---|---|---|---|
| 0 | CatName | | 6 | **WaterIntakeFact** *(interstitial)* |
| 1 | Gender | | 7 | NeuteredStatus |
| 2 | ProfilePhoto | | 8 | Coat |
| 3 | Age | | 9 | **CoatFact** *(interstitial)* |
| 4 | BodyCondition | | 10 | HealthConditions |
| 5 | Activity | | 11 | Breed |

Step widgets live in `widgets/steps/` — one file per step, all rendered inside
`WizardStepShell`.

The interstitials have a "Got it" CTA and hide the progress bar (`showProgress: !isFactStep`).
They are **still counted in the denominator**, so the bar reads 5/12 → (hidden) → 7/12.

### ⚠️ Adding or reordering a step touches ~8 places

`_stepNames` is the canonical list, but the page hard-codes parallel indices. All of these
must move together:

| Where | What |
|---|---|
| `bloc/cat_create_bloc.dart:21` | `_stepNames` — the canonical order |
| `create_cat_page.dart:31` | `const _totalSteps = 12` |
| `create_cat_page.dart:34` | `const _factSteps = {6, 9}` |
| `create_cat_page.dart:38` | `const _waterFactStep = 6` |
| `create_cat_page.dart:328` | a **second, inline** `const coatFactStep = 9` inside `_buildFactBackdrop` |
| `create_cat_page.dart:252-254` | `isPhotoStep == 2`, `isHealthStep == 10`, `isBreedStep == 11` |
| `create_cat_page.dart:296` | the `for (var i = 0; i < _totalSteps; i++)` page loop |

History shows the hazard: adding `BodyCondition` at index 4 shifted everything above it, and
the docs were not updated for months.

### ⚠️ `step_index` is a Mixpanel funnel contract

`_trackStepView` emits `step_index` + `step_name` + `is_edit_mode` on
**`Cat Wizard Step Viewed`**, which builds the wizard funnel and drop-off curve. Renumbering
silently invalidates historical funnel data. Filter `is_edit_mode = false` for the
first-time-creation drop-off.

This is the same hazard as onboarding's `OnBoardingPhase` ordinal — see
`lib/features/onboarding/README.md` §2.

---

## 2. Two contexts, one widget set

| | First-run onboarding | Standalone create / edit |
|---|---|---|
| Entry | The onboarding cascade pushes `CreateCatRoute(seededName, seededPhotoPath, onCreated:)` | "Add cat" / "Edit" CTA → `CreateCatRoute(cat:)` |
| Starting step | **1** (Gender) — the name was collected on the `profileName` beat | 0 (CatName) |
| Progress bar | Rebased: `currentStep - _initialStep` / `_totalSteps - _initialStep` → **11 steps** | 12 steps |
| Leading icon | Back | Close (×) on the first step (`useCloseIcon`) |
| Final CTA | `catCreateCtaCreateProfile` | `catCreateCtaSaveChanges` when `widget.cat != null` |
| Exit | `onCreated(context, summary)` — pushes the next screen **over** the wizard (forward slide) | `context.router.maybePop(summary)` |

`_seededFromOnboarding` is `widget.cat == null && seededName` non-empty. Note the photo step
still runs even when a photo was seeded.

### Edit mode is detected two different ways, on purpose

- **The page** branches on `widget.cat != null` — drives the CTA label and the close icon.
- **The bloc** branches on `event.cat?.id != null` — because a seeded model *without* a
  Firestore id is still a **creation**. Onboarding passes a populated `CatCreateModel` with no
  id; treating that as an edit would route it to `UpdateCatUsecase` and fail.

`_originalCat` is set only in real edit mode, and `isEditMode` downstream reads
`_originalCat != null`.

---

## 3. Bloc

`CatCreateBloc` — 5 events, 2 states.

**Events:** `CatCreateInitialEvent(cat?, initialStep)` · `CatCreateGoToNextStepEvent(step)` ·
`CatCreateStepChangedEvent(step)` · `CatCreateUpdateCatEvent(cat)` ·
`CatCreateCatEvent(cat, context, onCreated?)`.

**States:** `CatCreateInitial` and `CatCreateLoadedState(currentStep, cat, isSubmitting,
transientError, errorTick)`.

Four subtleties, each of which fixed a real bug:

1. **`CatCreateInitial` exists purely as a guard.** The page renders nothing interactive while
   in it, so the eagerly-built `PageView` children never run against an empty placeholder
   model. Without it, an auto-firing step could clobber seeded data — including wiping the
   edit id.
2. **The id is re-anchored on every update.** `_onCatCreateUpdateCatEvent` does
   `event.cat.id ?? _originalCat?.id`, because a step widget can fire `onChanged` during its
   first build — before `CatCreateInitialEvent` is processed — and that queued update would
   otherwise overwrite the seeded id, breaking "Save changes" with *"Cannot update cat without
   ID"*.
3. **Init lands directly on `initialStep`.** Emitting step 0 and then jumping would animate the
   `PageView` toward the name step and desync the controller from the bloc on the seeded path.
4. **`errorTick` increments per failure** so `BlocListener` sees a state change and re-fires an
   identical SnackBar. `isSubmitting` guards double-submit. `CatCreateError` is a semantic enum
   (`create` / `save`) — no user-facing copy lives in the bloc.

### ⚠️ The only bloc deliberately absent from `main.dart`

Every other bloc is in the root `MultiBlocProvider`. `CatCreateBloc` is resolved per session in
`CreateCatPage.initState` (`_bloc = sl<CatCreateBloc>()`) because a single app-wide instance
**leaked state across sessions**: a previous create flow left an id-less model behind, and a
spurious early update on that stale state clobbered the id seeded for an edit.

---

## 4. Persistence and side effects

On submit (`CatCreateCatEvent`):

- **Create** → `CreateCatUsecase` with the flattened field list, then `Cat Created`.
- **Edit** → `UpdateCatUsecase`, then **`invalidateProductPicksCache(catEntity.id)`** —
  cross-feature coupling into `cat/presentation/utils/cat_product_recommendations.dart`.
  Without it, the process-global picks cache would serve recommendations scored against the
  cat's *old* attributes until app restart.
- Either way the bloc returns a **`CatSummary`** (`CatSummary.fromModel`) so callers can render
  a recap. Onboarding consumes it on the result screen.

---

## 5. Analytics

| Event | When | Notable properties |
|---|---|---|
| `Cat Creation Started` / `Cat Edit Started` | init | `is_edit_mode`, `cat_name` (edit only) |
| `Cat Wizard Step Viewed` | every step view | `step_index`, `step_name`, `is_edit_mode` |
| `Cat Creation Step Completed` | forward move | `step_index`, `next_step_index` + names |
| `Cat Creation Step Abandoned` | **backward move only** | `from_step`, `to_step` + names |
| `Cat Created` | create success | `age_group`, `breed`, `gender`, `has_health_conditions`, `neutered`, `has_photo`, `creation_time_seconds` |
| `Cat Profile Updated` | edit success | `fields_changed` |
| `Cat Creation Failed` / `Cat Update Failed` | throw | `error_type`, `error_message`, `step_index` |

⚠️ **`Cat Creation Step Abandoned` fires on backward navigation, not on drop-off.** A user who
kills the app mid-wizard emits nothing — drop-off is derived from the `Cat Wizard Step Viewed`
funnel instead.

⚠️ **`fields_changed` comes from a hand-written 11-field diff** (`_getChangedFields`). A new
`CatCreateModel` field must be added there or it will silently never appear in analytics.
Note `profileImage` is reported whenever `profileImageFile != null` — i.e. "a photo was
picked", not "the photo differs from the old one".

---

## 6. Odds and ends

- **The breed list is 40 hard-coded strings** — `_breeds` in `create_cat_page.dart:70`, with
  `'Other'` pinned first. Only **6** of them have specialised rules in
  `cat_product_assessment.dart` (Maine Coon, Persian, Siamese, Sphynx, British Shorthair,
  Bengal); a further ~19 are matched as archetypes. The rest are cosmetic.
- **Life-stage thresholds are duplicated.** `ageGroupFromMonths` (`cat_entity.dart:4`) returns
  lowercase `kitten` / `adult` / `senior` at `<12` / `<120` months;
  `CatSummary.fromModel:71` re-implements the identical thresholds with capitalised display
  strings (`Kitten` / `Adult` / `Senior`). Two copies of one business rule.
- **Mappers:** `CatModelToCreateMapper` (existing cat → working model, edit entry) and
  `CatModelToEntityMapper` (working model → `CatEntity`, persist).

---

## 7. See also

- **`lib/features/onboarding/README.md`** — the cascade that launches this wizard, and the
  matching `step_index` funnel hazard.
- **`docs/design.md` §10** — the design-side view: shells, progress bar, wizard chrome.
- **Root `CLAUDE.md`** — the `CatEntity` field table this wizard populates.
