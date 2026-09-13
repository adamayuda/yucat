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

Only `flutter analyze` and `flutter test` — the schedule engine, weight bucketing,
allergen matching and calendar arithmetic are covered under `test/features/` (31 cases,
the list below as code), but nothing has rendered on a device. One layout bug has already
been found and fixed by running it; assume more. QA pass:

- [ ] A cat with **no records** → the setup sheet opens by itself; answer two dates and
      "Don't know" the third → Upcoming shows two dated items and one "To schedule";
      reopen the carnet → no sheet, but the "Set up in 30 seconds" card is still there.
- [ ] Dismiss the setup sheet by swiping it away → the card stays; tap it → the sheet
      returns; delete every record from History → the card comes back.
- [ ] A cat with **no records** (skip the setup) → every item reads "To schedule", none
      red, no fabricated past dates.
- [ ] Add a deworming dated ~3 months ago → the next one lands about today.
- [ ] "Mark as done" opens a date picker (default today, past only); pick a date three
      weeks back → the next due date moves from *that* day, and the timeline shows it.
- [ ] Log a neutering dated at 3 months on a 5-month intact kitten → the neutering item
      disappears, not a red "overdue".
- [ ] History tab: notes, vet and clinic text are wrapped in `MixpanelMask` — check a
      replay shows them blurred while the date and category pill stay readable.
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

### 🟡 Visibility + depth work (2026-09-13/14) — device QA not yet run

Nine phases built on top of the above, none run on a device yet. Two console steps first:
the **Storage rule** for `cats/{catId}/health/{file}` (§6) and a **deploy by name** of
`readHealthBooklet` (`functions/CLAUDE.md` §10). Then:

- [ ] Cat Detail row shows the next item + pill + "N records · last weight"; empty carnet →
      "Not set up yet"; airplane mode → the neutral static row, never the setup invite.
- [ ] Cat list: a pill only for items due within 30 days; tapping it opens the carnet.
- [ ] Home: a carnet with only long-interval acts logged → the all-clear card naming the
      next act; two cats with items due → "+1 more"; Profile's Health row count = both.
- [ ] Onboarding in en + one other locale: vaccine-reminder primer, "Vaccine & vet-visit
      reminders" option, intro quote fits.
- [ ] Vet: add → card + one-tap call; survives a wizard edit; Remove → field gone in
      Firestore; add sheet prefilled; name/phone blurred in a replay.
- [ ] Lifestyle: 4-step setup; outdoors → FeLV booster appears and deworming reads monthly;
      back to indoor → gone / quarterly.
- [ ] Weigh-in today → Cat Detail shows it; back-dated weigh-in → profile unchanged;
      "Learn more" opens the right article; airplane → link absent.
- [ ] Attachments (after the Storage rule): camera + library thumbnails; viewer zooms;
      delete record → object gone; delete cat → folder gone; upload failure → record kept
      + photo-specific SnackBar.
- [ ] Booklet (after the deploy): a real page in fr/en → rows with right dates, unsure rows
      unticked; untick one, edit a date, add → only those land; a food pack → "not a
      booklet"; airplane → "Try again".
- [ ] Share: full carnet → every section in Notes; empty carnet → three "no record"; French
      locale → French labels; iPad popover anchors.
- [ ] Course: a 7-day treatment → "7 days left" today, rings on the calendar through the
      end day, gone the day after (change the device date).
- [ ] Mixpanel: `Home Health Card Tapped` by `surface`; the four `health_*` People props;
      `Health Booklet Scanned / Imported`; `Health Carnet Shared`.

### 🟢 Deliberate deferrals — decisions, not omissions

Do not "fix" these without deciding to:

- **No reminders at all.** In-app only, by decision. See §12.
- **Home's recipe lane does not filter allergens** while the Recipes tab does, so the lane
  can show a recipe the tab hides. Filtering costs a cat fetch and Home is a discovery
  surface. See §9.
- **No `birthDate` on `CatEntity`** — approximated from `age`. See §4.
- **Heartworm is manual-add even for outdoor cats** — no region signal. See §5.

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
   - ⚠️ **An early dose counts for the band it stood in for** (`_earlyDosePhase`). A dose
     before the *first* band of a one-time act (neutering at 3 months, a microchip at 6
     weeks) completes it whatever the lead; otherwise a dose within
     `_kEarlyDoseToleranceMonths` (1 month) of the next band opening is treated as that
     band's dose — the 6-month FVRCP booster given at 5½ months, the first annual visit at
     11 months. Without this the band stayed unsatisfied and went **overdue the day it
     opened**, for an act the owner had just recorded, with no way to clear it but
     deleting the record. A dose further out than that (a kitten-series shot at 4½
     months) still leaves the band to do.
3. **Without history** → the start of whichever band applies, **clamped to today** if that
   band opened in the past. With **no age at all** only lifelong acts are offered
   (`_appliesAtUnknownAge`: applies at 12 months and open-ended thereafter) — the
   kitten-only FeLV series and the senior panel are not guessed at. An 11-year-old cat's first wellness visit was "due" at 12
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

## 4. ⚠️ The birth date is approximated — unless the owner gave one

`CatEntity.birthDate` is optional. The wizard's Age step offers "Know the exact birthday?"
beside the wheels; when a date is picked, `age` is derived from it (`monthsSince`) and the
document mapper re-derives `age` **and `ageGroup`** on every read, so the profile ages
itself — a kitten stops being a kitten without anyone editing it. `estimatedBirthDate`
uses the real date when present.

Without one, `age` is a months snapshot captured once and never aged, so the approximation
`now − age months` drifts by however long ago the profile was made. Two things make that
survivable rather than merely cheap:

- **It is only consulted when a protocol has no completed record.** Once one dose is
  logged, every later due date comes from `performedAt + interval` and the birth date is
  never read again. Drift decays to nothing as the carnet fills.
- **A dateless protocol renders as `toSchedule`, never as an alarm** (§3).

The kitten series is the one place the drift genuinely hurts, which is why the birthday
exists. Two invariants keep the two inputs from contradicting each other: picking a
birthday re-seeds the wheels from it, and moving a wheel afterwards **clears** the
birthday (`CatCreateModel.copyWith(clearBirthDate: true)`); and `toDocument` writes
`birth_date` **even when null**, because omitting the key would leave the old date in place
to override the new months on the next read. `birth_date` is the app's second `Timestamp`
field after `health_events`, converted at the mapper and never seen downstream.

## 5. Lifestyle: one question, two protocols

`CatEntity.lifestyle` (`indoor` / `outdoor`, `cat_lifestyle.dart`) is asked as the
**fourth step of the setup sheet** and editable from `LifestyleCard` on the Upcoming tab.
Stored on the cat document on the allergies contract (written only when set, cleared via
`updateCatLifestyle`). It changes the schedule, so the bloc rebuilds the state through
`_buildLoaded` rather than patching it — and the setup handler writes it **before** the
three dates, since the records feed protocols it gates.

What outdoor changes, and only this:

- **`felv_booster`** carries `requiresOutdoor: true` and is generated by
  `HealthProtocols.scheduledFor(cat)` only for an outdoor cat. Unknown lifestyle reads as
  indoor — the app never schedules a vaccine on a guess.
- **`deworming_internal`'s adult band** carries `outdoorIntervalDays: 30` beside its 91
  (ESCCAP: quarterly indoors, monthly for hunters and roamers). `ProtocolPhase.intervalFor`
  picks one. One protocol, one line in the schedule, no aliasing of records already logged.
  `deworming_monthly` is untouched: still manual-add, for raw-fed cats and young-children
  households, and for anyone already logging under it.

⚠️ **Heartworm stays manual-add even for outdoor cats.** It is endemic-region dependent and
the profile carries no region signal; scheduling a monthly preventive for a cat in a
non-endemic country would be the app asserting local practice.

The kitten deworming bands ignore lifestyle — the override sits on the adult band only.
Multi-cat and hunting remain unasked.

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

### Attachments

A record can carry one photo — a booklet page, a lab result — at
**`cats/{catId}/health/{eventId}.jpeg`** in Storage, named by the record so nothing has to
be looked up to delete it. The `File` never rides on the entity: `AddHealthEventUsecase`
takes it beside the record, and the repository does **write → upload → patch
`attachment_url`**, so the document exists before an object is named after it and the URL
is only stored once the object is there. A failed upload throws `HealthAttachmentFailed`
carrying the saved record; the bloc keeps the row and raises the SnackBar with
`HealthCarnetErrorKind.attachment` — losing a vaccination entry because a 2 MB upload
timed out would be the wrong trade. Uploads go through `lib/core/image/compress_jpeg.dart`
(1280 px, q85, EXIF stripped — the same helper the cat profile photo uses at 1024).
`deleteEvent` removes the object first, then the document; `CatDataSource.deleteCat`'s
cascade lists and clears the `health/` prefix. The timeline shows a 56 px thumbnail
(masked by session replay's image rule) that opens `HealthAttachmentViewer` — a plain
`MaterialPageRoute`, not an AutoRoute page.

⚠️ **The Storage path needs its own rule, in the console** (like the Firestore one in §0).
Cross-service rules can read Firestore, so ownership is the same `get()`:

```
match /cats/{catId}/health/{file} {
  allow read, write: if request.auth != null
    && firestore.get(/databases/(default)/documents/cats/$(catId)).data.user
       == /databases/(default)/documents/users/$(request.auth.uid);
}
```

Every upload fails until this exists — and by the contract above, the record still lands.

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

## 7b. First-open setup

A carnet with no history is a wall of seven or eight identical "to schedule" rows and an
empty calendar — accurate, and useless. `health_setup_sheet.dart` asks three dates
instead (last vaccine → `fvrcp`, last deworming → `deworming_internal`, last vet visit →
`annual_checkup`), each skippable, and each answer becomes an ordinary `done` record. Three
answers turn the wall into a dated schedule, which is what the Home card and the reminders
in later phases run on.

- **Presented by itself once per cat** — on the first load of an empty carnet
  (`_maybeOfferSetup`, post-frame). A prefs flag `health_setup_dismissed_<catId>` is set
  however the sheet closes, so a "not now" is honoured for ever; `HealthSetupCard` at the
  top of the Upcoming tab keeps it reachable while `history` is empty.
- **One event, sequential writes.** `HealthCarnetSetupCompletedEvent(drafts)` is handled
  by its own loop, *not* three `HealthCarnetAddRecordEvent`s: `_write` appends to the
  state it captured at entry, so concurrent calls would each emit a list missing the
  others' rows. A partial failure keeps what landed and bumps `errorTick`.
- "Last vaccine" is FVRCP, not rabies — the rabies interval is a property of the vial and
  needs its own question, which the add sheet asks.
- `HealthDateRow` is the shared date field (lifted out of the add sheet for this).

## 7c. Home surface

`HomeHealthNextUpCard` (in `lib/features/home/widgets/`) is the carnet's door on the
screen every user sees — Cat Detail reaches about one active subscriber in four. It shows
**one thing**, chosen by the pure `resolveNextUp(summaries)` in
`cat_health_summary_resolver.dart`: the nearest dated item across every cat (with a
"+N more" caption counting the household's other overdue / urgent / soon items), else the
setup invitation for the first cat with no history, else — every carnet set up and quiet —
an **all-clear** naming the next act beyond the 12-month horizon ("Next: FVRCP booster ·
March 2028", via `CatHealthSummary.nextBeyondHorizon`, which is only computed for a quiet
carnet). Setup outranks all-clear on purpose: one well-kept cat and one never set up is not
"all clear". The card is absent only for no cats or when every read failed.

⚠️ This supersedes the original "a well-kept carnet earns a quiet Home" rule. It was
accurate but cost the door exactly the users who keep the carnet best; the all-clear keeps
the same avatar / eyebrow / title / subtitle geometry, so the skeleton bone is unchanged.

`HomeBloc` resolves it after its cat fetch. ⚠️ **Reads go through
`health_events_cache.dart`, not the repository.** Home re-fires on every tab visit, after
every scan and on Cancel; without the mirror each fire would re-read every cat's whole
subcollection. The carnet's repository stays uncached (the page writes what it reads) — the
mirror is kept *by the writer*: `HealthCarnetBloc._buildLoaded` stores the full list on
every re-derive, so Home sees a new record without a fetch. Events are cached, never the
computed schedule, because `computeDueItems` takes `now`. A cat whose read fails is skipped;
if every cat is skipped the card hides, like the content lanes. Tapping pushes
`HealthCarnetRoute` and re-fires Home on return.

## 7d. Other surfaces — one resolver

Cat Detail's carnet row and the cat-list cards are live too, and all three surfaces
(with Home) read through **one** path: `presentation/utils/cat_health_summary_resolver.dart`.
`summarizeCatHealth(cat, events, now)` is the pure reducer (records + profile →
`CatHealthSummary`: nearest item, `hasHistory`, `recordCount`, `latestWeightKg`,
`pressingCount`, `dueSoonCount`); `resolveCatHealth` wraps it in the cache-or-fetch that
`HomeBloc` used to hand-roll, and `resolveHouseholdHealth` fans it out. Home's card, the
detail row and the list pill therefore cannot disagree about a cat.

⚠️ **A failed read resolves to `null`, never to an empty summary**, and every surface
renders its *neutral* copy on null — the static "Vaccines, visits and weight" on the row,
no pill on the card, no card on Home. The setup invite is only ever shown for a summary
that exists and has no history. "Couldn't read" must never read as "start over".

- **Cat Detail** (`_HealthCarnetCard`): title + `HealthUrgencyPill` on the nearest item,
  then "Rabies · in 3 days", then "4 records · last weight 4.7 kg". `CatDetailBloc`
  resolves the summary after emitting the cat (the row fills in a beat later) and re-derives
  it on `CatDetailHealthRefreshEvent`, fired on return from the carnet, and after a reload —
  an edit can change age or neutered status, which moves the schedule.
- **Cat listing** (`HealthDuePill` on `CatSummaryCard`): only for overdue / urgent / soon
  items — a pill on every card is no pill at all. Tapping the pill opens the carnet
  directly, not detail.
- **Profile** (`_LibraryRow` "Health record", first row of the library card): the household's
  overdue / urgent / soon count, or "Set up {cat}'s record" for the first cat with no
  history, or "All up to date". One cat opens its carnet; several open
  `showHealthCatPickerSheet`, whose rows carry each cat's own state. Hidden when no carnet
  could be read.
- **People properties** (`UserAnalyticsService.syncHealth`, from Home): `health_records_count`,
  `health_pending_count`, `health_setup_done`, `health_next_due_at` — the last has no unset,
  see `docs/analytics.md` §1.
- **Analytics**: all doors emit the same `Home Health Card Tapped` with a `surface`
  property, built by `healthEntryTapProperties` (`health_entry_analytics.dart`). The name
  is historical; keep it.

## 7e. Scan the vaccination booklet

The physical carnet is what the vet stamps; `readHealthBooklet` (see `functions/CLAUDE.md`
§3e) turns a photo of one page into *proposed* records. Two doors: a second CTA on
`HealthSetupCard`, and a row atop the add sheet's picker (the sheet closes first and calls
back into the page, so the capture never runs inside a dismissed sheet's context). Capture
is `pickPhotoFromSheet` + a 1600 px JPEG — **not** `ScannerRoute`, which pops into
`HomeBloc`'s theater; booklet pages are also often already in the library.

`health_booklet_review_sheet.dart` does the read (loading, then one toggleable row per act
with "Edit date"; rows the reader marked `low` confidence start **unticked**, so a misread
never lands by inertia) and returns the accepted drafts. `HealthBookletRecord.toDraft`
follows the add sheet's contract — empty title for a protocol-backed record, transcribed
title for a freeform one, an unknown id degrades to freeform, `intervalDays` only on rabies.
The bloc writes them through `_writeSequentially` (shared with the setup) as
`HealthCarnetImportRecordsEvent`. The photo is **never persisted** — not as an attachment,
not on the server — because it is medical PII with nothing to cache.

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

## 9b. Vet contact

`CatEntity.vet` (`CatVetContact`: name, clinic, phone, address — free text) sits on the
**cat document** on exactly the allergies contract: `CatDocumentMapper.toDocument` writes
`vet` only when set, so a wizard save can't wipe it, and clearing goes through
`CatRepository.updateCatVet(vet: null)` → `FieldValue.delete()`. Edited from
`VetContactCard` under the allergies card; "Remove vet" and a blank save both come back
as an **empty** contact, which the bloc turns into a removal. The card's one-tap call is
`url_launcher` `tel:`; the add sheet prefills vet/clinic from it. Name, clinic, address
and phone render inside `MixpanelMask`. ⚠️ Adding the field touched the `CatModel` trio
(`cat_model.dart`, both listing mappers) — `HealthCarnetRoute` takes a `CatModel`, so a
field missing there never reaches the carnet.

## 9c. Weigh-ins feed the profile; due items link to articles

**Weight.** A `done` record carrying `weightKg` that is the carnet's newest weighing
(`isLatestWeighing(draft, history)`, decided against the records *before* the write)
also becomes the cat document's `weight` via `updateCatWeight` — the number
`cat_product_assessment.dart` and the diet tips read, which was a wizard snapshot that
never moved. Best-effort after the record is saved; invalidates the product-picks cache and
emits `Cat Profile Updated { fields_changed: ['weight'], source: 'health_carnet' }`.
`weightCategory` — the owner's body-condition answer — is never touched. Cat Detail reloads
the cat on return from the carnet for this reason. ⚠️ Deferred, by design: a back-dated
weigh-in never syncs, and deleting the newest weight record does **not** roll the profile
back — the next weigh-in corrects it.

**Articles.** `healthProtocolArticleSlug(protocolId)` (`health_labels.dart`) maps every
protocol to a Firestore `articles` doc id — three dedicated pieces (dental, senior,
hide-pain) and the preventive-care calendar for the rest; a test asserts full coverage so a
new protocol cannot ship with a dead link. `HealthCarnetPage` loads the articles once per
language through the memoized repository (free after Home's lane) and passes
`DueItemCard.onLearnMore` only for a slug that resolved, so the link can never open an
error screen. Emits `Health Article Opened { protocol_id, slug }`.

## 9d. Share

The app-bar share icon hands the carnet to the system share sheet as **plain text**
(`buildHealthShareText`, `utils/health_share_text.dart`): profile line, the three core
vaccines with dates (rabies with its validity from the per-record interval), the next five
dated items, allergies, the vet. Text, not PDF, on purpose — it pastes into any chat and
needs no layout engine; PDF is deferred (§12). The builder is pure and tested against
`lookupAppLocalizations(Locale('en'))`. `share_plus` is the one package this added; the
button's own `BuildContext` supplies `sharePositionOrigin`, which iPad requires.

## 9e. Medication courses

A freeform **treatment** can carry a course: the add sheet asks "Course length (days)" and
"Doses per day", stored on the record as `course_end_at` (start + days − 1, inclusive) and
`doses_per_day`. Deliberately *not* a protocol: a course has no interval and nothing follows
it, so it never enters `computeDueItems`. `activeCourses(history, now)` (pure, tested) picks
the courses whose window contains today, soonest to finish first; `_buildLoaded` stores them
on `HealthCarnetLoadedState.courses`. Rendered as a "Medication" block on
`OngoingTreatmentsCard` — **one row per course** ("Amoxicillin · 2×/day · 5 days left"),
never one per day — and on the calendar as treatment-coloured rings from today to the end
day (the start day keeps the record's filled dot), with a section in the day panel. The
medication name is the owner's prose and is masked in replays. Once the end date passes the
record is plain history on the timeline.

Deferred, by decision: ticking individual doses, refills, a Home-card slot, and per-dose
reminders. The minimal shape answers "what is the cat on right now, for how much longer".

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
  up: there is no local-scheduling package in the project at all, and OneSignal's click
  listener **logs but does not route** (`Push Opened` only, see `docs/onesignal.md` §8),
  so a push could not deep-link into the carnet even if one were sent. `reminders_screen.dart` (onboarding phase 10) already collects
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
- Share is plain text only. A PDF (for a vet who wants a printout) would need a layout
  package the app does not ship; the text covers the sitter / travel / new-vet cases.
- Non-English copy is machine-drafted and wants a native pass, same caveat as the rest of
  the app's locales.

---

## 13. See also

- **Root `CLAUDE.md`** — the `CatEntity` field table the schedule reads.
- **`lib/features/cat_create/README.md`** — where `age` is captured, and what adding a real
  `birthDate` would touch.
- **`docs/design.md` §8** — `DSSegmentedControl`, added for this screen.
