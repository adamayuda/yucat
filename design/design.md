# YuCat Design System & Onboarding

Source of truth for the YuCat visual redesign. Reference app: **BitePal iOS** (screenshots in `design/BitePal iOS *` folders).

This document is the brief AND the running notes. Sections marked **Open** need a decision before implementation. Sections marked **Estimated** are eyeballed from screenshots and need pixel-verification on real devices.

---

## 1. Direction

YuCat adopts BitePal's design language wholesale:

- **Tinted pastel section backgrounds**, white card surfaces on top
- **Solid-black content-width pill CTAs** (not full-width, not brand-colored)
- **Chunky display typography** for headings; clean grotesque for body
- **Mascot-driven** — for YuCat, the *user's actual cat* (uploaded photo, name) is the mascot. Generic illustrated cat used pre-personalization (Phases A–C); user's cat takes over from Phase E onward.
- **Selection state = colored ring + ✓**, no fill change beyond a soft tint
- **Long, multi-phase onboarding** that interleaves marketing → survey → conviction → personalization → completion

YuCat's pink `#ED67CA` is **demoted** from primary UI color to brand mark only (logo, splash glyph). Black + pastels do all the heavy lifting.

---

## 2. Color tokens (Estimated)

### Section surface tints — page backgrounds

| Token | Approx hex | Used for |
|---|---|---|
| `tintLavender` | `#E8E5F0` | Splash, transition beats |
| `tintSky` | `#DCE9F4` | Welcome, value prop, "why YuCat works" |
| `tintMint` | `#D8F0DD` | Social proof, completion / success |
| `tintCoral` | `#F4D9D6` | Domain pitch, reminders (deferred) |
| `tintSand` | `#FAEBC8` | Rating ask, reviews |
| `tintAsh` | `#EFEEF0` | Surveys, neutral / form-heavy phases |

### Foreground / ink

| Token | Approx hex | Use |
|---|---|---|
| `inkPrimary` | `#0E0E14` | Headings, primary CTA bg, body |
| `inkSecondary` | `#5C5C66` | Helper text |
| `inkTertiary` | `#9999A3` | Captions, placeholders |
| `inkInverse` | `#FFFFFF` | Text-on-CTA, text-on-tint |

### Surfaces

| Token | Approx hex | Use |
|---|---|---|
| `surfaceCard` | `#FFFFFF` | Cards, option rows |
| `surfaceCardDim` | `#F5F5F8` | Disabled / nested card |

### Semantic / accent

| Token | Approx hex | Use |
|---|---|---|
| `accentSuccess` | `#36C078` | Selection ring, ✓, success — **Open #3** |
| `accentDanger` | `#E5564B` | Errors, destructive, "other apps" line |
| `accentInfo` | `#3F8CDB` | Info highlights |
| `brandPink` | `#ED67CA` | Logo / splash glyph only — **never** UI-primary |

---

## 3. Typography

Two-typeface system. Both shipped via `google_fonts`.

- **Display** — `Sora` (ExtraBold, weight 800) — free, loaded via `GoogleFonts.sora()` in `lib/config/themes/theme.dart`.
- **Body** — `Poppins` — kept from the legacy stack; clean grotesque, pairs cleanly with Sora.

### Type presets

| Token | Size / line / weight | Use |
|---|---|---|
| `displayHero` | 40 / 44 / 800 | Welcome headline, hero questions |
| `displayLg` | 32 / 38 / 800 | Step questions, "Track calories"-tier |
| `headlineMd` | 22 / 28 / 700 | Card titles, sub-section heads |
| `titleMd` | 18 / 24 / 600 | Option row labels |
| `bodyLg` | 16 / 24 / 500 | Body |
| `bodyMd` | 14 / 20 / 400 | Helper, secondary copy |
| `label` | 13 / 16 / 500 | Tags, chips, small CTAs |
| `caption` | 11 / 14 / 500 | Legal, micro-copy |

---

## 4. Spacing

Scale: `4, 8, 12, 16, 24, 32, 40, 48, 64`.

Existing `DSDimens.sizeXxxs..sizeXxl` covers 4–32; extend with `size3xl: 40`, `size4xl: 48`, `size5xl: 64`.

**Layout norms** (observed in BitePal):
- Page horizontal padding: `24`
- Heading anchored ~30% from top (or directly under back chip)
- Primary CTA anchored ~88–92% from top (account for iOS safe area)

## 5. Radii

| Token | Value | Use |
|---|---|---|
| `radiusSm` | 8 | Chips, small tags |
| `radiusMd` | 12 | Inputs, dense rows |
| `radiusLg` | 16 | Option rows, small cards |
| `radiusXl` | 24 | Hero cards, illustration cards |
| `radiusPill` | 999 | Pill CTAs |

## 6. Shadows

| Token | Value (approximate) |
|---|---|
| `e1` | `0px 1px 2px rgba(0,0,0,0.04)` — option rows |
| `e2` | `0px 4px 12px rgba(0,0,0,0.06)` — cards |
| `e3` | `0px 8px 24px rgba(0,0,0,0.08)` — hero / modal cards |

## 7. Motion

To document as we land animations. Initial defaults:

| Token | Value | Use |
|---|---|---|
| `durFast` | 150ms | Press / ripple |
| `durMed` | 250ms | Page transitions, selection |
| `durSlow` | 400ms | Hero, mascot reveal |
| `curveStandard` | `Curves.easeInOutCubic` | Default |
| `curveEmphasized` | `Curves.easeOutBack` | Pop-in elements |

---

## 8. Component catalog

Shared components live in `lib/presentation/components/`. Feature-specific widgets live next to their feature; only feature widgets used by **multiple** screens are listed below. Inspect the source for full props — this catalog is a one-line shape per component.

### 8a. Shared (`lib/presentation/components/`)

| Component | File | Shape |
|---|---|---|
| `OnboardingScaffold` | `onboarding_scaffold.dart` | Tinted bg + optional back chip + content + footer slot. Onboarding A–D screens. |
| `WizardStepShell` | `wizard_step_shell.dart` | Top nav (× back + progress bar) + content + sticky CTA. Modes: bottom-anchored (default) or `floatingNext` overlay. Optional `altCtaLabel` ("None of these" on HealthConditions). |
| `DSPillButton` | `ds_pill_button.dart` | Black-pill primary CTA with chevron. Variants: `primary` (black/inkInverse), `secondary` (white/inkPrimary). Props: `loading`, `leadingIcon`, `showChevron`, `verticalPadding`. Companion: `DSTextLink` for inline secondary text links. |
| `OnboardingFloatingButton` | `onboarding_floating_button.dart` | Wraps `DSPillButton` with a consistent bottom margin. Placed as the LAST child of a survey screen's content column (preceding `Spacer`/`Expanded` pushes it down) so the CTA sits bottom-anchored at the same height across onboarding screens 2–4 (scan / attribution / proof chart). |
| `DSCard` | `ds_card.dart` | White surface, `DSRadii.xl`, `e2` shadow. Optional `onTap` ripple. Base for nearly every grouping. |
| `DSChip` | `ds_chip.dart` | Tinted soft pill with optional leading icon. Used for emphasis chips on stat/quote screens. |
| `DSOptionRow` | `ds_option_row.dart` | White pill row, optional emoji/icon + label + radio indicator. Variants: `accent: success` (green ✓) / `danger` (coral ✗ — HealthConditions step). |
| `DSStatPill` | `ds_stat_pill.dart` | Soft-tinted pill, bold number + body text. Phase C0 social proof. |
| `DSQuoteCard` | `ds_quote_card.dart` | Logo + body + underlined source link. Phase C2 domain pitch. |
| `DSDotIndicator` | `ds_dot_indicator.dart` | Wraps `smooth_page_indicator` for value-prop carousel (A2–A4). |
| `DSStateView` | `ds_state_view.dart` | Centered illustration + headline + body + optional CTA. Constructors `DSStateView.error()` (Error.gif default + "Try again") and `DSStateView.empty()` (caller picks illustration). All empty/error states funnel through this. |
| `DSBottomNav` | `ds_bottom_nav.dart` | Floating pill nav. `DSBottomNavItem(icon, label)` per tab; `accentSuccessSoft` selection chip; `surfaceCardDim` track. |
| `CatAvatar` | `cat_avatar.dart` | Circular cat photo or `Icons.pets` fallback on `tintLavender` disc. Default 56px; takes `size`. |
| `MascotSpeechBubble` | `mascot_speech_bubble.dart` | Mascot illustration + speech bubble with `CustomPainter` tail. Used by every cat-create wizard step. |
| `LineChartCard` | `line_chart_card.dart` | Two-line chart (your line vs theirs) inside a `DSCard`. Phase C0. |

### 8b. Feature-bundled but reused across screens

| Component | File | Shape |
|---|---|---|
| `ProductRowCard` | `lib/features/search_products/presentation/widgets/product_row_card.dart` | 64×64 thumb (or `tintLavender` placeholder) + name + brand + soft score pill + chevron. Used by Search results AND Product Listing. |
| `SearchTextField` | `lib/features/search_products/presentation/widgets/search_text_field.dart` | White pill input, `e1` shadow, search icon prefix. Search page. |
| `RingScore` | `lib/features/product_detail/presentation/widgets/ring_score.dart` | Circular ring score: `CircularProgressIndicator(value)` + centered number. Color buckets (green / amber / coral) follow `ProductRatingColor`. Used on product analysis card and per-cat verdict cards. |
| `HatchedPlaceholder` | `lib/features/product_detail/presentation/widgets/hatched_placeholder.dart` | 45° hatch `CustomPainter` + "PRODUCT" tag corner. Hero fallback when `imageUrl` is null. |
| `AnalysisChipRow` | `lib/features/product_detail/presentation/widgets/analysis_chip_row.dart` | Wrapping pill chips: success (`+ ...` green) / caution (`! ...` amber). Truncates to 3 pros + 1 con. |

### 8c. App-shell layout rules

Patterns shared across the post-onboarding app (`MainRoute`).

**Per-tab background palette.** All three main tabs use `tintLavender` as the page background:

| Tab | Background |
|---|---|
| Search | `tintLavender` |
| Home | `tintLavender` |
| Cats | `tintLavender` |

`MainPage` is `Scaffold(extendBody: true, backgroundColor: Colors.transparent)` so the lavender extends edge-to-edge under the floating-nav pill. Don't set per-page Scaffold backgrounds inside the tab pages — the shell handles it. Modal routes outside the tab shell (`ProductDetailRoute`, `ProductListingRoute`, `CatDetailRoute`, `CreateCatRoute`, `ProfileRoute`, `PaywallRoute`) set their own `tintLavender` bg directly, since they're not under `MainPage`.

**Inline header pattern.** `TopAppBar` was retired; every tab and modal renders an inline header with one of two shapes:

- **Tab pages** (Cats, Search): `Row(displayLg + trailing icon)` with `~24` horizontal padding. Search adds a `SearchTextField` below.
- **Modal pages** (Cat Detail, Product Listing, Profile, Product Detail): leading 28px `Icons.chevron_left` `IconButton`, optional centered title (`headlineMd`), optional trailing action icons. Product Detail is the only screen using circular white-disc action buttons (bookmark + ⋯) — these may graduate into `DSCircleIconButton` if a second use appears.

If a third call-site appears with the same outer shape, extract `DSAppBar` / `DSPageHeader` (P1 in the remaining-work survey).

**Bottom inset for floating nav.** Any scroll surface inside a tab page (lists, dashboards) needs a bottom padding of `MediaQuery.of(context).padding.bottom + ~96` so the last item clears the floating-nav pill. Modal pages don't need this — they're full-screen with no nav.

---

## 9. Onboarding flow (new YuCat sequence)

Triggered when `SharedPreferences['onboarding_completed'] != true`. Total ~18–20 screens.

### Phase A — Welcome (5 screens)

| # | Screen | Background | Notes |
|---|---|---|---|
| A0 | Splash | `tintLavender` | YuCat logo (pink), auto-advance |
| A1 | Welcome / fork | `tintSky` | `displayHero` "Find food that fits your cat" + `PillButton` "Get started" + text link "Restore purchases" *(YuCat is anonymous-auth — no real account, but RevenueCat returners need an entry point)* |
| A2 | Value prop 1/3 | `tintAsh` | Scan-photo card visual + "Scan any cat food" + `DotIndicator` (1/3) + "Next" |
| A3 | Value prop 2/3 | `tintMint` | Cat avatar collage + "Personalized to your cat" + "Next" |
| A4 | Value prop 3/3 | `tintSand` | Search-result list visual + "Or browse our catalog" + "Continue" |

### Phase B — Attribution (1–2 screens)

| # | Screen | Background | Notes |
|---|---|---|---|
| B0 | "How did you hear about us?" | `tintAsh` | `OptionRow` list: Instagram / TikTok / Youtube / Vet / App Store / Friend / Influencer. CTA flips Skip → Next on selection |
| B1 | Influencer/vet name (conditional) | `tintAsh` | Keyboard-up screen, `PillButton` "No, skip" / "Next" |

### Phase C — Conviction (3 screens)

| # | Screen | Background | Notes |
|---|---|---|---|
| C0 | Social proof | `tintMint` | `LineChartCard` (cat's diet score over time) + `StatPill` — **Open #4** (need real stat) |
| C1 | "Why YuCat works" | `tintSky` | 3-card angled collage: Barcode scan / Cat profile / Vet-backed assessment + "Let's go" |
| C2 | Domain pitch | `tintCoral` | `displayLg` "1 in 3 cats are overweight" + `QuoteCard` — **Open #5** (real source) |

### Phase D — Personalization (10 screens, absorbs cat-create wizard)

| # | Screen | Background | Notes |
|---|---|---|---|
| D0 | "Let's get to know your cat" | `tintLavender` | Generic illustrated cat + `PillButton` "Add my cat". Bridge screen replacing BitePal's "meet your raccoon" beat |
| D1 | Wizard: **CatName** | white over tint | `WizardStepShell`, progress 1/9 |
| D2 | Wizard: **ProfilePhoto** | white over tint | 2/9 |
| D3 | Wizard: **Gender** | white over tint | 3/9 |
| D4 | Wizard: **Age** | white over tint | 4/9 |
| D5 | Wizard: **Activity** | white over tint | 5/9 |
| D6 | Wizard: **NeuteredStatus** | white over tint | 6/9 |
| D7 | Wizard: **Coat** | white over tint | 7/9 |
| D8 | Wizard: **HealthConditions** | white over tint | 8/9 |
| D9 | Wizard: **Breed** | white over tint | 9/9, final step ⇒ E0 |

Step order is the canonical `_stepNames` list in `lib/features/cat_create/bloc/cat_create_bloc.dart` — **do not reorder** without updating the bloc.

### Phase E — Completion (1 screen)

| # | Screen | Background | Notes |
|---|---|---|---|
| E0 | "You're all set, {catName}" | `tintMint` | Uploaded cat avatar + `PillButton` "Start scanning" → `MainRoute`. Sets `onboarding_completed = true` |

### Deferred (not in v1)

- **Reminders setup** (BitePal 14–16) — YuCat has no push notification system today. Don't ship a fake screen; defer until push is built.
- **App Store rating ask** (BitePal 13) — pre-product-use rating asks are weakly performant; defer until we know the right lifecycle moment.

---

## 10. Cat-create reuse (two contexts, one widget set)

The 9 step widgets and `cat_create_bloc` are shared. Only the parent shell differs.

| Context | Trigger | Shell behavior |
|---|---|---|
| First-time user | `onboarding_completed != true` | Wrapped in `OnboardingScaffold` + `WizardStepShell`. Back chip returns to D0. Final step → E0. |
| Adding nth cat | "Add cat" CTA on `CatListingPage` (gated by `cat_tracking_service` free-tier check; paywall if at limit) | Modal route + `WizardStepShell`. Close (×) instead of back. Final step → `CatDetailRoute`. |

Existing entities to reuse:
- `lib/features/cat_create/bloc/cat_create_bloc.dart` (state, `_stepNames`)
- `lib/features/cat_create/bloc/cat_create_event.dart` (events; `CatCreateGoToNextStepEvent`, `CatCreateStepChangedEvent`)
- `lib/features/cat_create/widgets/steps/*` (content widgets, rendered inside the shell)
- `lib/services/cat_tracking_service.dart` (free-tier gate at `_maxFreeCats = 1`)

---

## 11. Implementation phases

### Shipped

1. ✅ **Token foundation** — `lib/config/themes/theme.dart` extended with sections 2–6 above; Sora + Poppins loaded via `google_fonts`.
2. ✅ **Component library** — see §8 for shipped components.
3. ✅ **`WizardStepShell` extraction** — the 9 cat-create step widgets render inside the shell; standalone "add cat" flow + onboarding flow share the same widgets.
4. ✅ **Onboarding rebuild** — Phases A–E implemented (welcome → value carousel → attribution → conviction → personalization → success).
5. ✅ **Post-onboarding redesign** — Home/Scanner (B3), Cat listing (B4), Cat detail (B5), Search (B6), Product listing (B7), Product detail v1+v2 (B8/B12), Profile (B9), Bottom nav (B2), Empty/Loading/Error states (B11).

### Outstanding

See `/Users/adam.ayuda/.claude/plans/lets-update-claude-md-with-fluffy-liskov.md` for the full survey. Headline items:

- **B10** — Custom paywall UI on top of `purchases_flutter` (drops `RevenueCatUI.presentPaywall()`).
- **Code hygiene sweep** — pre-existing `flutter analyze` warnings (~30 lines).
- **Visual QA pass** — side-by-side iOS-sim comparison vs BitePal reference for the post-onboarding tabs.

---

## 12. Open decisions

### Resolved

1. ~~**Display typeface**~~ — **Sora ExtraBold** shipped.
2. ~~**Body typeface**~~ — **Poppins** kept.
3. ~~**Selection accent**~~ — **Green** (`accentSuccess #36C078`) for selection ✓; coral (`coralAccent #FF7A59`) reserved for emphasis (chips, slider, "BEST VALUE" tag).
4. ~~**Social-proof stat (C0)**~~ — **APOP** (Association for Pet Obesity Prevention) — "61% of US cats are overweight or obese". Sourced + linked to `petobesityprevention.org`.
5. ~~**Domain pitch source (C2)**~~ — **WSAVA Global Nutrition Guidelines** — linked to `wsava.org/global-guidelines/global-nutrition-guidelines/`. Editorial copy points at the guidelines rather than fabricating a direct quote.
6. ~~**Cat illustration style**~~ — **GIF animations** ship today (`assets/images/Illustrations/`: Welcome, Add new cat, Loading, Error, plus the 4 multi-step home loader frames). Hand-drawn vectors deferred.
7. ~~**Push notifications**~~ — **Deferred**. Reminders phase out of v1.

### Still open

_None._
