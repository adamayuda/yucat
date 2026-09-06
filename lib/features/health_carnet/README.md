# Health carnet

The per-cat veterinary record: what has been done, and what is due next.

This is the source of truth for the feature — the protocol catalogue and the reasoning
behind it, the birth-date approximation, the storage contract, and the known gaps.
Read it before touching `lib/features/health_carnet/`.

---

## 0. Outstanding work — start here

Everything in the agreed scope is built and `flutter analyze` is clean. What is *not* done:

### 🔴 Blocking: Firestore rules are not deployed

The carnet reads and writes `cats/{catId}/health_events/{eventId}`, and **that path has no
security rule**. Every read fails `permission-denied`, which surfaces as the retryable
error card — so the feature looks broken rather than empty.

Rules for this project live in the **Firebase console**, not the repo (`firebase.json` has
no `firestore` block, so committing a rules file here would replace the console ruleset
wholesale). Subcollection rules do **not** inherit from the parent document. In project
`yucat-d8fb5`, add:

```
match /cats/{catId}/health_events/{eventId} {
  allow read, write: if request.auth != null
    && get(/databases/$(database)/documents/cats/$(catId)).data.user
       == /databases/$(database)/documents/users/$(request.auth.uid);
}
```

Note the `get()` — ownership is a `DocumentReference`, not a uid string, so the check costs
one document read per rule evaluation.

### 🟡 Never run on a device

Only `flutter analyze` plus throwaway pure-Dart harnesses (schedule engine, weight
bucketing, allergen matching, calendar arithmetic — none kept, the repo has no `test/`).
One layout bug has already been found and fixed by running it; assume more. QA pass:

- [ ] A cat with **no records** → every item reads "To schedule", none red, no fabricated
      past dates.
- [ ] Add a deworming dated ~3 months ago → the next one lands about today.
- [ ] A **kitten** profile (`age < 6`) → FVRCP shows as a 3-weekly *series*, not one shot.
- [ ] A `neutered == true` cat → no neutering item.
- [ ] **Airplane mode** → retryable error state, *not* an empty state.
- [ ] History tab: weight chart appears only with ≥2 months of weighings; swipe-to-delete
      re-derives the schedule.
- [ ] Calendar: filled dots for recorded acts, rings for scheduled; **nothing** on today
      for a fresh carnet (`toSchedule` items are excluded by design).
- [ ] Allergies: declare chicken → a chicken product shows the named con on Product
      Detail, and chicken recipes disappear from the Recipes **tab**.
- [ ] Delete the cat, then confirm in the console that `health_events` is gone — this
      exercises the pre-existing cascade cleanup in `CatDataSource.deleteCat`, which has
      never run against real documents.
- [ ] One non-English locale: dates format correctly, the calendar starts the week on
      Monday, and no string is still English.

### 🟡 Not verified

- **Mixpanel**: no event has been seen landing. Check `Health Carnet Viewed` and
  `Health Task Completed` arrive with `tracking_version = v2` and a `protocol_id`.
- **Non-English copy is machine-drafted** (152 new keys × 5 locales) and wants a native
  pass, same caveat as the rest of the app.

### 🟢 Deliberate deferrals — decisions, not omissions

Do not "fix" these without deciding to:

- **No reminders at all.** In-app only, by decision. See §12.
- **Home's recipe lane does not filter allergens** while the Recipes tab does, so the lane
  can show a recipe the tab hides. Filtering costs a cat fetch and Home is a discovery
  surface. See §9.
- **No `birthDate` on `CatEntity`** — approximated from `age`. See §4.
- **Lifestyle protocols are manual-add only** — the profile carries no indoor/outdoor
  signal. See §5.

---

## 1. The one idea

**The schedule is never stored.** It is a pure function of the cat's records plus its
profile:

```
computeDueItems(cat, history, now) -> List<HealthDueItem>
```

History is the only thing persisted. Nothing can drift out of sync with it, because
there is nothing else to keep in sync. Every mutation funnels through
`HealthCarnetBloc._buildLoaded`, which re-derives the whole schedule rather than
patching a cached list.

---

## 2. The protocol catalogue

`domain/entities/health_protocol.dart`. Sources: **WSAVA Vaccination Guidelines**,
**AAFP/AAHA Feline Vaccination Guidelines (2020)**, **AAFP Feline Life Stage Guidelines
(2021)**, **ESCCAP** for parasite control.

A protocol is a list of **age-banded phases** — `{fromAgeMonths, toAgeMonths,
intervalDays}` — not a single interval, because feline schedules genuinely are banded.
FVRCP is `[(1.5–4mo, every 21d), (6mo, once), (12mo+, every 1095d)]`. Deworming is
`[(0.75–3mo, 14d), (3–6mo, 30d), (6mo+, 91d)]`. One structure covers every act.

### Obligation tiers

| Tier | Meaning | Treatment |
|---|---|---|
| `legal` | Required by law in *some* jurisdictions (rabies, microchip) | Carries a "requirements vary by country" note. ⚠️ **The app must never assert what the user's local law is.** |
| `core` | Recommended for every cat by veterinary consensus | Full urgency |
| `lifestyle` | Depends on outdoor access / multi-cat / hunting | `autoSchedule: false` — see §5 |
| `optional` | Vet-directed one-offs | Never auto-generated |

### What is in it, and why

- **FVRCP** — kitten series every 3 weeks from 6–8 wk to ≥16 wk, booster at 6 months,
  then triennially.
- **Rabies** — from 12 wk, then per the vial used. ⚠️ **The booster interval is a
  property of the product, not of the cat** (1 or 3 years), so it is stored per record as
  `interval_days` and asked for in the add sheet. Unknown defaults to the conservative 365.
- **FeLV** — core for kittens after a FeLV/FIV test; becomes `lifestyle` after year one.
  Modelled as two protocols (`felv`, `felv_booster`) rather than one whose tier changes.
- **Deworming / external antiparasitics** — ESCCAP cadence; fleas and ticks monthly,
  year-round.
- **`annual_checkup`** — annually to age 10, **twice yearly from 10**. ⚠️ The weigh-in and
  the oral exam are **not** separate protocols: they happen at the same appointment, and
  three due items for one vet visit would be noise.
- **`dental_scaling`** — `optional` with **no phases**, so the engine can never generate
  it. Scaling is vet-indicated, not clock-driven, and the app must not schedule an
  anaesthetic procedure.
- **`neutering`** — by 5 months; `suppressWhenNeutered` drops it once the profile says so.
- **`senior_panel`** — annually from 84 months.
- **`condition_follow_up`** — `requiresHealthCondition`, driven by `cat.healthConditions`.

⚠️ **FIP vaccination is deliberately absent.** AAFP/WSAVA do not recommend it; it must not
be added.

---

## 3. Due-date derivation

For each protocol:

1. Find the latest `done` record with that `protocol_id`.
2. **With history** → `due = performedAt + interval`, where interval is
   `record.intervalDays ?? phaseAt(ageAtThatDose)?.intervalDays ?? defaultIntervalDays`.
   The age used is the age **at that dose**, not today — a kitten dosed at 2 months
   follows the 3-weekly band even if it is 9 months old now.
   - If that phase is **one-time** (or the dose landed in a gap between bands), advance to
     the next band instead of declaring the protocol finished. This is what carries FVRCP
     from its 6-month booster to the triennial adult schedule. No next band → the protocol
     is complete and drops out (microchip, neutering, retrovirus test).
3. **Without history** → the start of whichever band applies, **clamped to today** if that
   band opened in the past. An 11-year-old cat's first wellness visit was "due" at 12
   months; printing that literal date would read as *"planned for September 2016"*.
4. A `snoozed` record pushes this one occurrence out: `due = max(due, latestSnooze.dueAt)`.

### Urgency, and why `toSchedule` exists

`overdue` · `urgent` (≤7d) · `soon` (≤30d) · `later` · **`toSchedule`**.

A protocol with **no record at all** whose date has passed is `toSchedule`, never
`overdue` — and it renders with no date line and a neutral pill. That is not politeness,
it is accuracy: it means *"your carnet has a gap"*, not *"your cat missed a vaccine"*. The
owner may simply never have logged it, and the date behind it comes from an approximated
birth date (§4). Only an item with real history, or one the user actively snoozed, can go
red.

⚠️ **The 12-month horizon.** Items due more than `_kHorizonDays` out are dropped. Without
it an adult cat's list carries a triennial FVRCP due in 2029 and a senior panel due in
2030 — neither actionable, and both inflating the "à faire" count into meaninglessness.

---

## 4. ⚠️ The birth date is approximated

`CatEntity` has **no `birthDate`** — only `age` in months, captured once in the create
wizard and never aged since. `estimatedBirthDate` derives `now − age months`, so it drifts
by however long ago the profile was made.

Two things make that survivable rather than merely cheap:

- **It is only consulted when a protocol has no completed record.** Once one dose is
  logged, every later due date comes from `performedAt + interval` and the birth date is
  never read again. Drift decays to nothing as the carnet fills.
- **A dateless protocol renders as `toSchedule`, never as an alarm** (§3).

Kitten-series accuracy is the one place this genuinely hurts. Adding a real `birthDate` to
the profile is the fix when it becomes a complaint — it would touch `CatEntity`, both cat
mappers, the wizard's Age step, `CatSummary.fromModel`, and the hand-written 11-field diff
behind `Cat Profile Updated`.

---

## 5. Lifestyle protocols are manual-add only

The profile carries **no indoor/outdoor, multi-cat, hunting or region signal**, so the app
cannot know whether adult FeLV boosters, monthly deworming or heartworm prevention apply.
Those protocols carry `autoSchedule: false`: they never appear in the schedule, but they
*are* in the "Add an act" picker, so a user who knows they apply can opt in and get a
recurring due date from then on.

Adding a lifestyle question to the create wizard is the follow-up that would let the
engine generate them.

---

## 6. Storage

`cats/{catId}/health_events/{eventId}` — a subcollection that **predates this feature**.
`CatDataSource.deleteCat` already cascade-deletes it, with a comment explaining that
Firestore does not cascade. Nothing had ever written to it. Adopting the path inherits
correct delete semantics for free.

Field naming is `snake_case`, matching the dominant convention in `CatDataSource`.

Two rules inherited from `litter_display_codec.dart`:

- **Enums persist by stable wire string, never by index.** Reordering an enum must not
  silently reinterpret saved rows.
- **One codec, one place to change.** `HealthEventDocumentMapper` is the single
  boundary — the food side has two byte-identical codecs in unrelated features, which is
  why `dataUnavailable` had to be fixed twice.

⚠️ **This is the app's first `Timestamp` and first `DateTime` persisted to Firestore.** No
other model stores a date at all.

### Protocol-backed records store an **empty title**

The timeline renders them from `protocol_id` via `healthProtocolName`, so a record logged
in French still reads correctly after the user switches to German. Only freeform records
carry a user-authored title — which is also why the add sheet hides the title field when a
protocol is chosen.

### Snoozes are not history

A `snoozed` record carries only a pushed-back `due_at`. It is excluded from
`HealthCarnetLoadedState.history`, so it never appears in the timeline as an act the cat
had, and each new snooze **supersedes** the last (the old rows are deleted) so they cannot
pile up in a collection the user cannot see.

### ⚠️ Security rules live in the console, not the repo

`firebase.json` has no `firestore` block — a rules file here would replace the console
ruleset wholesale. **Subcollection rules do not inherit from the parent document**, so
project `yucat-d8fb5` needs an explicit block, and because ownership is a
`DocumentReference` the check costs a `get()` per evaluation:

```
match /cats/{catId}/health_events/{eventId} {
  allow read, write: if request.auth != null
    && get(/databases/$(database)/documents/cats/$(catId)).data.user
       == /databases/$(database)/documents/users/$(request.auth.uid);
}
```

Every read fails `permission-denied` until this exists.

### No composite index needed

The datasource reads the whole subcollection (tens of documents) and sorts in memory —
there is no `where` + `orderBy` pair, so no index. ⚠️ Do not add a filtered query without
also creating the index out-of-band.

---

## 7. Layering notes

- **`HealthEventDataSource` throws** on a read failure, following
  `RecipeFirestoreDataSource` and *not* `CatDataSource` (which returns null and lets its
  repository collapse it to `[]`). A network error that rendered "no records yet" would
  tell an owner their vaccination history had vanished. Writes rethrow so the failure
  analytics event carries the real cause.
- **The repository does not cache**, unlike `RecipesRepositoryImpl`. Recipes are a
  read-only catalogue; health records are written by the very page that reads them.
- **`HealthCarnetBloc` is not in `main.dart`'s `MultiBlocProvider`** — the fourth bloc
  after `CatCreateBloc`, `FoodGuideBloc` and `ArticlesBloc`. The page owns it and closes
  it in `dispose`; a root instance would carry one cat's records into the next.
- **The engine takes no `AppLocalizations` and no dimension weights.** Unlike
  `cat_diet_recommendations.dart`, copy here is 1:1 with the protocol and resolved at
  render time by `health_labels.dart`, which keeps the engine testable without a
  `BuildContext`. And a schedule is ordered by *due date*, not dimension priority, so it
  has no reason to become the **third** copy of `_wHealth`/`_wWeight`/… — keep it that way.

---

## 8. History tab

Reads `HealthCarnetLoadedState.history` — `done` records only. `snoozed` rows are
scheduling residue and would otherwise appear in the timeline as acts the cat never had.

### Weight chart

`monthlyWeightBuckets` (in `cat_health_schedule.dart`, next to `weightSeries`) reduces the
series to **one reading per month, latest wins**, capped at 6 and chronological. Months
with no weighing are **skipped, not drawn empty** — a cat weighed three times a year would
otherwise be three bars in a field of gaps. The trade-off is an x-axis that is not evenly
spaced in time, which is why every bar carries its month and its value.

The chart and the summary tile both read those buckets, so the tile's *"+0.3 kg since
April"* can never disagree with the bars above it.

⚠️ **The y-axis is zoomed to the data, not anchored at zero.** A cat moving 4.5 → 4.8 kg
would otherwise render as five identical bars. The cost is that small changes look large —
which for a health metric could alarm someone over 100 g of ordinary fluctuation. The
mitigation is that **every bar is labelled with its actual value**, so the number overrides
the impression the shape gives. Do not remove that label.

The chart only renders with **two or more** months: one bar is a dot, not a trend.

Built from plain widgets, not a `CustomPainter` — the project has no charting package, and
`LineChartCard` is a marketing illustration whose painter takes no data at all.

### Deleting a record

Swipe from the trailing edge → `showDSConfirmDialog`. ⚠️ `confirmDismiss` returns **false**
even when the user confirms: it dispatches the delete and lets the bloc's next state drop
the row. Letting `Dismissible` remove the widget itself would animate it away before the
write was known to have succeeded, and a failed delete would then have to animate it back.

Deleting re-derives the schedule, so removing the last deworming record moves that due date
back to "to schedule".

---

## 9. Allergies, and what they change elsewhere

Allergies are **profile data, not a dated act**, so they live on the cat document
(`CatEntity.allergies`) rather than in `health_events`. The carnet is just where they are
edited.

### Keys, never free text

`CatAllergen` (`lib/features/cat/domain/entities/cat_allergen.dart`) is the catalogue: a
stable snake_case `key`, a `kind`, and English `needles`. Keying is what makes the list
useful beyond display — a key can be matched against canonical-English product and recipe
text while the owner reads an ARB label. Free text would be unmatchable in five of the six
locales. ⚠️ Keys are persisted; renaming one orphans every cat that declared it.

**Environmental allergens carry no needles and are never matched.** Dust and pollen belong
in a health record and matter at the vet, but scanning an ingredient list for "dust" would
only produce noise.

### ⚠️ The wizard must not be able to wipe the list

`CatDocumentMapper.toDocument` writes `allergies` **only when non-empty**. A cat-wizard
save builds a `CatEntity` with no allergies, and omitting the key from a Firestore
`.update()` leaves the stored value alone. The corollary is that the mapper can never
*clear* the field, so clearing goes through `CatRepository.updateCatAllergies`, which
writes `[]` outright.

### Product scan — flags

`_evaluateDeclaredAllergens` in `cat_product_assessment.dart` matches declared allergens
against `pros + cons + name + brand` and adds a named `health`-dimension con (−14 each,
clamped at −24 in total: one allergen already sinks the verdict, and the message is the
same either way). It is separate from the existing `food_allergies` branch, which is the
generic "this cat reacts to something" heuristic — this one names the culprit.

⚠️ Matching is plain substring, with **no word boundary and no "-free" exclusion**, so
`"contains no chicken"` triggers and `fish` matches inside `fish oil`. That is inherited
deliberately from `_kCommonAllergens`, which has always behaved this way: fixing it in one
branch only would make the two disagree about the same product. On an allergy warning,
over-reporting is the safer direction.

### Recipes — hides

`RecipeDocumentMapper` resolves `allergenKeys` **from `data['ingredients']`, the flat
English field**, never the localized list. ⚠️ `RecipeIngredient.name` is documented as
canonical English but the mapper substitutes the translated names when one exists, so by
the time the UI sees a recipe its ingredient names are in the user's language. Matching
those against English needles would silently do nothing outside an English build.

`RecipesLoadedState.excludedAllergens` is the **union of every cat's** allergies — a treat
is made once and shared, so anything that would harm any cat in the house should not be
suggested. `hiddenByAllergies` feeds a notice on the tab: silently shrinking a catalogue
would leave someone hunting for a recipe they remember seeing.

⚠️ **Only the Recipes tab opts in** (`RecipesInitialEvent.excludeCatAllergens`). Home's
swimlane does not, because it is a discovery surface and a second cat read on every Home
load is a real cost for six teaser cards. The consequence is that **the lane can show a
recipe the tab hides**, and tapping through still opens it.

⚠️ `_declaredAllergens` swallows a cat-fetch failure and returns an empty set, so a
problem there degrades to "no filtering" rather than taking down the recipe list. That
makes it a soft failure, which is exactly why the product scan flags allergens
independently — this must never be the only thing between a cat and an allergen.

---

## 10. Calendar tab

A month grid over everything **dated**, past and future, with a detail panel for the
selected day.

⚠️ **`toSchedule` items are excluded.** They are dated today by construction — a
placeholder standing in for "no record yet", not a deadline — so plotting them would stack
seven markers on today's cell for a fresh carnet and imply an urgency none of them has. A
footnote under the grid says so, rather than leaving the omission silent.

Markers distinguish past from future by **shape, not colour alone**: a filled dot per
recorded act (tinted by category), a ring per scheduled one. Three per day maximum — a
fourth only makes the cell noisy, and three already makes the point.

The displayed month and the selected day are **local widget state**, not bloc state. They
are pure view navigation, and routing them through `HealthCarnetBloc` would churn a state
that also drives the other two tabs.

`health_calendar_layout.dart` holds the grid arithmetic and **imports no Flutter**, so it
can be exercised without building a widget. ⚠️ `DateTime.weekday` is 1=Mon..7=Sun while
`MaterialLocalizations.firstDayOfWeekIndex` is 0=Sun..6=Sat; the `% 7` reconciles them.
Getting it wrong shifts a whole month by a day, and **shifts differently per locale** —
`en` starts on Sunday and the other five start on Monday, so an English-only check would
not catch it.

---

## 11. Analytics

`Health Carnet Viewed` · `Health Carnet Tab Changed` · `Health Task Completed` ·
`Health Task Snoozed` · `Health Record Added` · `Health Record Deleted` ·
`Health Allergies Updated` · `Health Carnet Load Failed`.

⚠️ **`Health Task Completed` carries `protocol_id` *and* `was_overdue`.** That pair is the
point of the feature — a completion only means something relative to whether the app
surfaced the act in time. Break down by `protocol_id`; never aggregate completions alone.

---

## 12. Known gaps

- **No reminders of any kind.** In-app only by decision. Worth knowing before picking this
  up: there is no local-scheduling package in the project at all, and OneSignal here is
  receive-only with **no click listener**, so a push could not deep-link into the carnet
  even if one were sent. `reminders_screen.dart` (onboarding phase 10) already collects
  reminder-type choices into a `Set<int>` that is discarded.
- **Anonymous auth means a reinstall orphans the carnet.** Unlike the SharedPreferences
  stores, which hold derived data, this is user-authored primary data — the loss is a bug,
  not a cache miss. Real accounts are the fix.
- The calendar shows no marker for anything still "to schedule", by design — those have no
  real date. A cat with an empty carnet therefore sees an empty calendar.
- Month paging is unbounded: you can scroll to 2043 and find nothing there.
- Allergies are per-cat but the recipe filter is the union across cats, so a two-cat
  household sees a list narrowed for both. There is no per-cat recipe view to narrow it
  properly.
- The weight chart has no tap target and no way to correct a mistyped weight other than
  deleting the record it came from.
- Non-English copy is machine-drafted and wants a native pass, same caveat as the rest of
  the app's locales.

---

## 13. See also

- **Root `CLAUDE.md`** — the `CatEntity` field table the schedule reads.
- **`lib/features/cat_create/README.md`** — where `age` is captured, and what adding a real
  `birthDate` would touch.
- **`docs/design.md` §8** — `DSSegmentedControl`, added for this screen.
