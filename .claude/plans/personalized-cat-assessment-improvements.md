# Personalize the cat product assessment: fix DMB, compute a per-cat score, expand breeds/conditions, use the unused cat fields

## Context

`lib/features/product_detail/presentation/utils/cat_product_assessment.dart` produces the per-cat pros/cons shown on `ProductDetail`. It works, but a code-level audit (5 May 2026) surfaced:

- **A silent accuracy bug**: nutrient thresholds compare *as-fed* percentages, so wet food (~75% moisture) is mis-rated against dry food. A wet food with 10% protein is read as "low protein" when on dry-matter basis it's ~40% — excellent.
- **No personalized score**: the function returns pros/cons but the UI still shows the generic `product.score`, identical for a healthy 3-year-old and a 16-year-old with kidney disease.
- **3 of 9 cat profile fields are unused**: `gender`, `coatType`, raw `age`, raw `weight`, and the `neutered` boolean never reach the rule engine.
- **6 breeds, 8 health conditions** when the catalog is much larger and several common conditions (hyperthyroidism, HCM, pancreatitis, IBD, arthritis…) have well-established dietary implications.
- **Empty `adult` branch** and **missing default rules** mean a healthy adult Domestic Shorthair gets *no* personalization beyond weight/activity.

This plan covers the personalization-engine improvements only. **Cross-reference**: the saved migration plan at `.claude/plans/haiku-migration-and-algolia-fix.md` includes a Phase 6 to enrich the LLM response with structured fields (e.g. `phosphorus`, `taurineMg`, `aafcoLifeStage`, `healthBenefits[]`, `allergens[]`) — when that ships, the keyword-scan helpers in this file collapse into clean structured-field reads. Both plans are independently valuable; do this one first because it doesn't depend on the backend migration.

## Approach (ordered by impact, not by file)

### Phase 1 — Dry-matter-basis (DMB) normalization [biggest accuracy win]

The single highest-impact fix. Without it, every threshold in the file is silently wrong for wet food, which is half the catalog.

1. **Add nutrient helpers** in a new `lib/features/product_detail/presentation/utils/nutrient_math.dart`:
   ```dart
   double dmb(double asFedPercent, double moisture) {
     if (moisture >= 100) return 0;
     return asFedPercent / (100 - moisture) * 100;
   }
   ```
   Plus thin wrappers `proteinDmb(product)`, `fatDmb(product)`, `carbsDmb(product)`, `fiberDmb(product)`, `ashDmb(product)` that read the model and apply DMB.

2. **Calories**: today thresholds like `> 360 kcal/100g` are as-fed. Either:
   - Apply DMB the same way (`kcal / (100-moisture) * 100`), OR
   - Use `kcal/kg dry matter` directly if the model exposes it (it doesn't today — verify and add if needed).
   Pick one and apply consistently.

3. **Replace every nutrient threshold comparison in `cat_product_assessment.dart`** to read DMB-normalized values. Concretely, every line of the form `if (product.protein > 35)` → `if (proteinDmb(product) > 35)`.

4. **Threshold values stay the same** — the existing thresholds were already designed for dry food (DMB-equivalent), so they apply correctly once we normalize wet food up to DMB.

5. **Caveat**: `score` from the LLM is generic and was generated however it was generated. Don't try to fix the generic score retroactively — the personalized score (Phase 2) sits on top and dominates.

### Phase 2 — Personalized score computation

Today `evaluateCatProduct` returns `{pros, cons}` only. Extend the contract so each rule emits a `weight`, then derive a single 0-100 personalized score.

1. **New data shape** in the same file:
   ```dart
   class AssessmentItem {
     final String text;
     final int weight; // signed: + for pros, − for cons
     final String tag; // stable id like "kidney_low_phosphorus" — for analytics + debugging
     const AssessmentItem({required this.text, required this.weight, required this.tag});
   }

   class CatProductAssessment {
     final List<AssessmentItem> pros;
     final List<AssessmentItem> cons;
     final int personalizedScore;
   }
   ```

2. **Weight scale guideline** (so weights stay coherent across rules):
   - **+/− 4-6**: weak/general signal (e.g., "high protein for active cat")
   - **+/− 8-12**: meaningful match (e.g., "joint support ingredients for senior")
   - **+/− 15-20**: critical match for a known condition (e.g., "low phosphorus for kidney disease cat")
   - **+/− 20-25**: directly contraindicated (e.g., "high phosphorus for kidney disease cat", "high fat for pancreatitis cat")

3. **Score formula** (in `evaluateCatProduct`):
   ```dart
   final base = product.score; // generic 0-100 from the LLM
   final delta = pros.fold<int>(0, (s, p) => s + p.weight) +
                 cons.fold<int>(0, (s, c) => s + c.weight); // cons are already negative
   final personalized = (base + delta).clamp(0, 100);
   ```
   That keeps the generic baseline and lets condition-specific signals push it up or down — meaning a generic 80 product can become a 95 for a healthy kitten or a 55 for a kidney-disease senior.

4. **UI integration** — find where `product.score` is rendered on `ProductDetail` and switch to the assessment's `personalizedScore` when a cat is selected. Show generic score when no cat is selected (cat-listing previews, etc.). Look for `product.score` references in `lib/features/product_detail/presentation/widgets/`.

5. **Migration**: every existing rule needs to be wrapped in `AssessmentItem(text: ..., weight: ..., tag: ...)`. Mechanical refactor, ~50 call sites in `cat_product_assessment.dart`.

### Phase 3 — Use the cat fields we currently ignore

1. **`gender`** — male cats have ~3× the urinary blockage risk. Add a `evaluateGenderProsCons`:
   - Male + neutered → boost weight on urinary-support pros (+5 to existing weight) and on high-mineral cons.
   - Female lactating → already covered by `neuteredStatus == "lactating"`.

2. **`coatType`** — fires independently of breed:
   - Long-haired → reward omega-3, fiber 4-6%, hairball claims (+8). Penalize low-fat (<12%) (−6).
   - Hairless / Sphynx-style → reward higher fat (+8). (Currently only fires if `breed == "sphynx"`.)

3. **Raw `age` (int)** — refine ageGroup:
   - 12+ years → "geriatric" overlay on top of senior rules: stronger weight on kidney-friendly, joint, and palatability signals (+5 to existing).
   - <0.5 years (very young kitten) → require very high protein (>40% DMB) and avoid adult formulas.

4. **Raw `weight` (kg)** — compute approximate daily caloric requirement, flag products whose serving size doesn't fit:
   - Adult maintenance: ~50-60 kcal/kg/day.
   - Use this only as a soft signal; raw weight rules are easy to get wrong, so weight ±3 max.

5. **`neutered` (bool)** — collapse with `neuteredStatus`. If `neutered == true` and `neuteredStatus == null`, treat as `neutered`. Don't add separate rules; just resolve the data inconsistency.

### Phase 4 — Expand breeds

Current 6 (Maine Coon, Persian, Siamese, Sphynx, British Shorthair, Bengal) → target ~15.

Add (with rule highlights — keep concise, follow existing rule style):

- **Ragdoll** — HCM risk: reward taurine, omega-3, low sodium. Penalize plant-only-protein.
- **Scottish Fold** — joint disease congenital: reward glucosamine/chondroitin even at any age (+10).
- **Norwegian Forest / Ragamuffin** — large breed, mirror Maine Coon rules.
- **Abyssinian** — renal amyloidosis risk + high energy: reward kidney-friendly + high protein. Slight tension; weights kept moderate.
- **Burmese** — diabetes predisposition: low carb (<15% DMB) reward, high carb (>25%) penalty.
- **Russian Blue** — urinary + sedentary: urinary support reward, calorie-dense penalty.
- **Devon Rex / Cornish Rex** — Sphynx-like skin: mirror Sphynx rules.
- **Exotic Shorthair** — brachycephalic like Persian: hairball + omega-3 + kibble-shape considerations (the kibble-shape signal can wait until LLM provides structured `kibbleShape`).
- **Manx** — spinal/digestive: limited ingredient + moderate fiber.
- **Savannah / Bengal Hybrid** — mirror Bengal high-protein rules.
- **Default fallback (Domestic Shorthair / mixed / unspecified)** — generic complete-and-balanced rules: reward AAFCO statement (when structured), penalize >30% carbs DMB, reward moderate protein 30-40% DMB.

Group by similarity in code (Maine Coon + Norwegian Forest + Ragamuffin share rules; Sphynx + Devon Rex + Cornish Rex share rules) — use a `Set<String>` membership check rather than 15 case statements.

### Phase 5 — Expand health conditions

Current 8 → target ~14. Add these with new condition keys (must be added to whatever cat-create wizard step lists conditions — see `cat_create/widgets/steps/health_conditions_step.dart` or similar; verify path before editing):

- **`hyperthyroidism`** — common in seniors. Penalize fish-heavy (high iodine), reward low-iodine claims, reward L-carnitine. Critical for cats 10+.
- **`heart_disease`** (HCM + general) — reward taurine, omega-3, low sodium. Penalize plant-only protein, high sodium.
- **`pancreatitis`** — penalize high fat (>15% DMB) heavily (−20). Reward highly digestible, single-protein.
- **`ibd`** — reward hydrolyzed/novel protein, limited ingredient. Penalize common allergens. (Mostly overlaps with food_allergies — but separate weighting because IBD is more severe.)
- **`liver_disease`** — reward high-quality protein (animal-source), low copper. Penalize copper-rich organs (liver, lamb).
- **`arthritis`** — reward glucosamine, chondroitin, omega-3, MSM. Independent from "senior" so younger arthritic cats also benefit.
- **`constipation_megacolon`** — reward soluble fiber + high moisture (wet food bonus +12). Penalize very low fiber.
- **`fiv_felv`** — reward immune support, high protein, omega-3. Don't avoid raw — too domain-specific to encode safely.
- **`cancer`** — reward high protein, omega-3. Penalize simple carbs (sugar, white rice).

Check `lib/features/cat_create/widgets/steps/` for the health-conditions step UI and add the new keys there with user-friendly labels.

### Phase 6 — Default rules + adult branch

1. **Adult branch** in `evaluateAgeProsCons`: today empty. Add baseline rules that fire when no other dimension dominates:
   - Reward moderate protein (30-40% DMB) (+5).
   - Reward AAFCO maintenance complete-and-balanced when structured field exists (+8). For now, fall back to scanning for "complete and balanced" / "AAFCO" in pros/cons (+5).
   - Penalize protein <26% DMB (−6).
   - Penalize carbs >35% DMB (−6).

2. **Default activity** when `activityLevel == null` or `"medium"`: apply baseline (no penalty either direction). Currently falls through silently — add an explicit branch.

3. **Default breed** when breed is null, "domestic shorthair", "mixed", or unrecognized: apply Phase 4's "default fallback" rule set.

### Phase 7 — Tighten the keyword vocabularies (interim only)

These helpers (`_hasJointSupport`, `_isKidneyFriendly`, `_hasOmega3`, `_hasManyFillers`, `_isLimitedIngredient`, `_containsCommonAllergen`, `_hasNovelProtein`) all scan `(pros + cons).join(' ').toLowerCase()`. They're brittle by design. The migration plan's Phase 6 (structured fields from the LLM) is the proper fix — but until that ships, expand the vocabularies so they catch more real-world phrasings:

- `_hasJointSupport`: + `msm`, `green-lipped`, `green lipped mussel`, `hyaluronic`, `joint health`, `joint support`
- `_isKidneyFriendly`: + `renal diet`, `k/d`, `phosphorus binder`, `restricted phosphorus`
- `_hasOmega3`: + `epa`, `dha`, `flaxseed`, `chia`, `algae oil`, `krill`
- `_hasManyFillers`: + `rice`, `potato`, `pea protein`, `tapioca`, `sorghum`, `oat` (raise threshold from 2 to 3 since the list grew)
- `_isLimitedIngredient`: + `lid`, `hypoallergenic`, `hydrolyzed`
- `_containsCommonAllergen`: + `dairy`, `egg`, `lamb`, `turkey`, `gluten`
- `_hasNovelProtein`: + `insect`, `quail`, `ostrich`, `alligator`, `crocodile`, `pheasant`

Replace `_isWetFood` (currently `moisture > 70`) with `product.foodType == 'wet'` — the structured field already exists.

Delete `_estimateIngredientCount` — it counts commas in a `pros + cons` string after the word "ingredients", which essentially never appears there. False signal.

## Critical files to modify

- `lib/features/product_detail/presentation/utils/cat_product_assessment.dart` — every rule, plus new data shape, plus new evaluators (`evaluateGenderProsCons`, `evaluateCoatTypeProsCons`)
- `lib/features/product_detail/presentation/utils/nutrient_math.dart` — **new file** with DMB helpers
- `lib/features/product_detail/presentation/widgets/` — find the score-rendering widget (likely a header card on ProductDetail page); switch from `product.score` to `personalizedScore` when a cat is selected
- `lib/features/cat_create/widgets/steps/` — find the health-conditions step (filename TBD; verify before editing) and add new condition keys + labels
- `lib/features/cat_create/widgets/steps/` — same for breed step; add new breed options
- `lib/features/product_detail/presentation/bloc/` — wire the personalized score into state if not already (verify by reading the bloc)
- `CLAUDE.md` — update the "Product Assessment Logic" section to describe the new dimensions, the DMB normalization, and the personalized score formula

## Verification

1. **Unit-test DMB normalization** in isolation with 4 fixtures:
   - Wet food protein 10%, moisture 78% → DMB ~45%
   - Dry food protein 35%, moisture 10% → DMB ~39%
   - Edge case moisture 100% → returns 0 (no NaN)
   - Edge case moisture 0 → DMB == as-fed
2. **Manual regression** on 5 sample products from Algolia (mix of wet/dry):
   - Healthy adult DSH: expect personalized score within ±5 of generic
   - Senior with kidney disease: expect significantly lower for high-phosphorus dry foods
   - Kitten: expect high scores for high-protein/fat formulas, low scores for senior formulas
   - Diabetic Burmese: expect very low scores for high-carb foods
   - Pancreatitis cat: expect very low scores for fat >15% DMB
3. **Run `flutter analyze`** — must be clean.
4. **Visual check**: open `ProductDetail` for a wet and a dry food side-by-side with the same cat; pros/cons should now reflect comparable DMB-based judgments rather than penalizing wet food on raw protein percentage.
5. **Snapshot logging** (optional but recommended): emit an analytics event `Personalized Score Computed` with `{productId, catId, baseScore, personalizedScore, prosCount, consCount}` so we can monitor distribution shifts post-deploy.

## Out of scope (deferred to other plans)

- LLM-returned structured fields (`phosphorus`, `taurineMg`, `aafcoLifeStage`, `healthBenefits[]`, `allergens[]`, `ingredientQuality`) — handled in `.claude/plans/haiku-migration-and-algolia-fix.md` Phase 6. When that lands, the Phase 7 keyword vocabularies and several keyword helpers in this file collapse into clean structured-field reads. Both plans are independent.
- Backfilling existing Algolia rows with new structured fields — only matters once the LLM emits them.
- Vet-reviewed weight calibration — current weights are educated guesses; running the assessment past a feline nutritionist for sign-off is a separate, valuable, non-engineering task.
- Multi-cat aggregate scoring (e.g., "best food for all 3 of your cats") — out of scope; today the user picks one cat.

## Expected outcome

- Wet food assessments stop being silently wrong (Phase 1 alone)
- Per-cat personalized 0-100 score displayed on ProductDetail (Phase 2)
- Coverage: 6 → ~15 breeds, 8 → ~14 health conditions, 6 → 9 cat fields actively used
- Adult/healthy/Domestic Shorthair cats get meaningful assessments (default rules, Phase 6) instead of empty pros/cons
