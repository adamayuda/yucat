# YuCat Design System & Onboarding

Source of truth for the YuCat design system. The redesign was modelled on **BitePal iOS**; its
reference screenshots lived in `design/` and were never committed (gitignored) — they have
since been deleted, so the BitePal comparisons below are historical context, not something you
can re-check.

This document began as the redesign brief and is now the **reference** for the shipped system.
§2–§7 are transcribed from `lib/config/themes/theme.dart` and must be updated in the same
commit as any token change — this doc has drifted badly once already (it specified the wrong
typefaces and the wrong paywall accent for months). §8 is the component catalog; add to it
when you add a shared component.

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

## 2. Color tokens

All values below are transcribed from `lib/config/themes/theme.dart` (`DSColors`) — exact,
not eyeballed. If you change a token, change it here in the same commit.

### Page background

| Token | Hex | Used for |
|---|---|---|
| `pageBackground` | `#F2EDF8` | **Every post-onboarding scaffold** — the `MainPage` shell and its nav fade gradient, all three tabs, and every modal route outside the shell. Deliberately *not* `tintLavender`: that token still tints small surfaces which sit on white cards and must stay visibly darker. |

### Section surface tints

| Token | Hex | Used for |
|---|---|---|
| `tintLavender` | `#E8E5F0` | Splash, transition beats, avatar discs (`CatAvatar`), image placeholders, mascot halos |
| `tintSky` | `#DCE9F4` | Welcome, value prop, "why YuCat works" |
| `tintMint` | `#D8F0DD` | Social proof, completion / success |
| `tintCoral` | `#F4D9D6` | Domain pitch, reminders |
| `tintSand` | `#FAEBC8` | Rating ask, reviews |
| `tintAsh` | `#EFEEF0` | Surveys, neutral / form-heavy phases; `DSShimmer` base |
| `tintCloud` | `#EFEEF5` | Onboarding neutral backgrounds + gradient base |

### Soft pastel tints — gradient endpoints / highlighted surfaces

| Token | Hex |
|---|---|
| `tintBlueSoft` | `#E7EEFA` |
| `tintCoralSoft` | `#F8CDC6` |
| `tintSkyBright` | `#F7FBFE` |
| `tintMintSoft` | `#DFEFE1` |
| `tintSandSoft` | `#F8EADA` |
| `tintCream` | `#FFF4DC` |
| `tintGreySoft` | `#E2DFE8` |

### Foreground / ink

| Token | Hex | Use |
|---|---|---|
| `inkPrimary` | `#0E0E14` | Headings, primary CTA bg, body |
| `inkSecondary` | `#5C5C66` | Helper text |
| `inkTertiary` | `#9999A3` | Captions, placeholders |
| `inkInverse` | `#FFFFFF` | Text-on-CTA, text-on-tint |

### Surfaces

| Token | Hex | Use |
|---|---|---|
| `surfaceCard` | `#FFFFFF` | Cards, option rows |
| `surfaceCardDim` | `#F5F5F8` | Disabled / nested card; `DSBottomNav` track |

### Semantic / accent

| Token | Hex | Use |
|---|---|---|
| `accentSuccess` | `#36C078` | Selection ring, ✓, success |
| `accentSuccessSoft` | `#E3F5EA` | `DSBottomNav` selection chip, soft success surfaces |
| `accentDanger` | `#E5564B` | Errors, destructive, "other apps" line |
| `accentInfo` | `#3F8CDB` | Info highlights |
| `coralAccent` | `#FF7A59` | Selection accent — chips, slider, selected card border |
| `coralSurface` | `#FFF1ED` | Soft coral surface behind `coralAccent` |
| `brandPink` | `#ED67CA` | Logo / splash glyph only — **never** UI-primary |
| `splashPink` | `#FDD4DD` | Splash background (matches the pink baked into `logo.svg`) |
| `paywallAccent` | `#3F8CDB` | Paywall-only accent (selection, badges) — feature-scoped, replaces green within the paywall |
| `paywallAccentSoft` | `#E3EEFA` | Paywall highlighted backgrounds |

> The paywall accent is **blue**. It was coral (`#EC6A6A`) in an earlier revision — if you
> find coral in a paywall mock, the mock predates the re-theme.

### Decorative star palette

`star-sharp.svg` / `star-round.svg` are colour-agnostic; tint at the call site with a
`ColorFilter`. Consumed by `MascotIllustration` and `DSSparkleDecor`.

| Token | Hex |
|---|---|
| `starGold` | `#FEDD9F` |
| `starCyan` | `#ADE7E3` |
| `starBlue` | `#408AF2` |
| `starGrey` | `#CDCADB` |
| `starCoral` | `#FF7761` |
| `starTan` | `#F3DCD3` |

### Gradients (`DSGradients`)

A first-class token family — 13 gradients. Prefer these over inline `LinearGradient`s.

| Token | Direction | Colors |
|---|---|---|
| `paywallBadge` | left→right | `#2E7BC4 → #5FA3E0` |
| `paywallHero` | top→bottom | `#9FC9EF → #C4DEF6` |
| `onboardingWhyYucat` | top→bottom | `#CAD8FF → tintCloud` |
| `onboardingProofChart` | top→bottom | `#E3FFDD → tintCloud` |
| `onboardingHealthIntro` | top→bottom | `#DFE6FD → tintCloud` |
| `onboardingCurrentFood` | top→bottom | `#C2A5E4 → #EFEEF5` |
| `onboardingSuccess` | top→bottom | `#E5FEDE → tintCloud` |
| `onboardingReminders` | top→bottom | `#FEF8E6 → tintCloud` |
| `onboardingNotifPrimer` | top→bottom | `tintCoralSoft → tintCoral → #F3EEEC` (stops `0 / .45 / 1`) |
| `catCreateBackground` | top→bottom | `#A5CAFF → tintCloud` |
| `homeBackground` | top→bottom | `#EDEAF7 → tintCloud` |
| `homeScanCard` | ↘ diagonal | `tintCoralSoft → tintCoral` |
| `homeProfileCard` | ↘ diagonal | `#DFF6E6 → #BFEBCF` |

### ⚠️ Legacy palette — deprecated, do not use in new code

`theme.dart:6-29` still carries the pre-redesign palette, and `AppTheme.lightTheme` still
wires some of it (`scaffoldBackgroundColor: white`, bottom-nav `primary`, input
`inputLightGrey`). "Prefer the design tokens" means the tokens **above**, not these:

`primary` · `primaryVibrant` · `primaryFocus` · `primaryDisabled` · `primarySurface` ·
`primaryLight` · `primaryMuted` · `black` (`#4A4A4A`, *not* `inkPrimary`) · `darkBlue` ·
`bodyText` · `inputDarkGrey` · `placeholder` · `darkGrey` · `inputLightGrey` · `border` ·
`lightGrey` · `surface` · `white` · `green` · `red`

`DSColors.black` is the trap: it's a mid-grey, not the near-black `inkPrimary` you want.

---

## 3. Typography

Two-typeface system, but **only body ships via `google_fonts`**.

- **Display** — **Bricolage Grotesque**, a **bundled variable font** (declared under `fonts:`
  in `pubspec.yaml`, family `BricolageGrotesque`). Not a `google_fonts` lookup.
- **Body** — **DM Sans**, via `GoogleFonts.dmSans()`.

> An earlier revision of this doc specified Sora + Poppins. Both typefaces were replaced;
> the doc wasn't. Bricolage + DM Sans is what ships.

All display styles come from one helper — `DSTextStyles.title(size)` — so only the size
varies. It applies `height: 0.92`, `letterSpacing: size * -0.013`, and the variable-font
axes `wght 800` (heaviest) + `wdth 75` (condensed). Tight leading and negative tracking are
what give headings their chunky, condensed look; don't override them per-screen.

### Type presets

| Token | Size / line-height / weight | Family | Use |
|---|---|---|---|
| `displayHero` | 44 / 0.92 / wght 800 | Bricolage | Welcome headline, hero questions |
| `displayLg` | 36 / 0.92 / wght 800 | Bricolage | Step questions, tab headers |
| `headlineMd` | 24 / 0.92 / wght 800 | Bricolage | Card titles, sub-section heads |
| `titleMd` | 18 / 24 / w700 | DM Sans | Option row labels |
| `bodyLg` | 16 / 24 / w500 | DM Sans | Body |
| `bodyMd` | 14 / 20 / w400 | DM Sans | Helper, secondary copy (`inkSecondary`) |
| `label` | 13 / 16 / w600 | DM Sans | Tags, chips, small CTAs |
| `caption` | 11 / 14 / w500 | DM Sans | Legal, micro-copy (`inkTertiary`) |

`bodyMd` and `caption` default to `inkSecondary` / `inkTertiary` respectively; the rest
default to `inkPrimary`.

---

## 4. Spacing

Scale (`DSDimens`, shipped): `2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 64`.

| Token | Value | | Token | Value |
|---|---|---|---|---|
| `sizeXxxxs` | 2 | | `sizeXl` | 28 |
| `sizeXxxs` | 4 | | `sizeXxl` | 32 |
| `sizeXxs` | 8 | | `size3xl` | 40 |
| `sizeXs` | 12 | | `size4xl` | 48 |
| `sizeS` | 16 | | `size5xl` | 64 |
| `sizeM` | 20 | | | |
| `sizeL` | 24 | | | |

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

`DSMotion`, shipped:

| Token | Value | Use |
|---|---|---|
| `durFast` | 150ms | Press / ripple |
| `durMed` | 250ms | Page transitions, selection |
| `durSlow` | 400ms | Hero, mascot reveal |
| `curveStandard` | `Curves.easeInOutCubic` | Default |
| `curveEmphasized` | `Curves.easeOutBack` | Pop-in elements |
| `curveDecelerate` | `Curves.easeOut` | Settle / fade-out |

---

## 8. Component catalog

Shared components live in `lib/presentation/components/`. Feature-specific widgets live next to their feature; only feature widgets used by **multiple** screens are listed below. Inspect the source for full props — this catalog is a one-line shape per component.

### 8a. Shared (`lib/presentation/components/`)

| Component | File | Shape |
|---|---|---|
| `OnboardingScaffold` | `onboarding_scaffold.dart` | Tinted bg + optional back chip + content + footer slot. Onboarding A–D screens. |
| `WizardStepShell` | `wizard_step_shell.dart` | Top nav (× back + progress bar) + content + sticky CTA. Modes: bottom-anchored (default) or `floatingNext` overlay. Optional `altCtaLabel` ("None of these" on HealthConditions). |
| `DSPillButton` | `ds_pill_button.dart` | Black-pill primary CTA with chevron. Variants: `primary` (black/inkInverse), `secondary` (white/inkPrimary), `danger` (`accentDanger`/inkInverse, for destructive CTAs). Props: `loading`, `leadingIcon`, `showChevron`, `verticalPadding`. Companion: `DSTextLink` for inline secondary text links. |
| `OnboardingFloatingButton` | `onboarding_floating_button.dart` | Wraps `DSPillButton` with a consistent bottom margin. Placed as the LAST child of a survey screen's content column (preceding `Spacer`/`Expanded` pushes it down) so the CTA sits bottom-anchored at the same height across onboarding screens 2–4 (scan / attribution / proof chart). |
| `DSCard` | `ds_card.dart` | White surface, `DSRadii.xl`, `e2` shadow. Optional `onTap` ripple. Base for nearly every grouping. |
| `DSChip` | `ds_chip.dart` | Tinted soft pill with optional leading icon. Used for emphasis chips on stat/quote screens. |
| `DSOptionRow` | `ds_option_row.dart` | White pill row, optional emoji/icon + label + radio indicator. Variants: `accent: success` (green ✓) / `danger` (coral ✗ — HealthConditions step). |
| `DSStatPill` | `ds_stat_pill.dart` | Soft-tinted pill, bold number + body text. Phase C0 social proof. |
| `DSQuoteCard` | `ds_quote_card.dart` | Logo + body + underlined source link. Phase C2 domain pitch. |
| `DSDotIndicator` | `ds_dot_indicator.dart` | Wraps `smooth_page_indicator` for value-prop carousel (A2–A4). |
| `DSStateView` | `ds_state_view.dart` | Centered `MascotIllustration` + headline + body + optional CTA. Constructors `DSStateView.error()` (thinking cat on `tintCoral` + "Try again") and `DSStateView.empty()` (caller picks `mascotAsset` + `tint`). All empty/error states funnel through this. |
| `MascotIllustration` | `mascot_illustration.dart` | Cat mascot SVG on a tinted circular halo, framed by gently-twinkling stars (native bob/twinkle, `animate` toggle). The single playful illustration for loading/empty/error — used by `AppLoadingWidget` and `DSStateView`. **No raster GIFs** (legacy `Illustrations/*.gif` removed). |
| `DSConfirmDialog` | `ds_confirm_dialog.dart` | Centered confirmation via `showDSConfirmDialog(...)`. White `surfaceCard`, `DSRadii.xl`, tinted icon badge (`tintCoral`/`accentDanger` when `destructive`), `headlineMd` title + `bodyMd` body, stacked CTA: `DSPillButton` (`danger` variant) over a `DSTextLink` cancel. Returns `true`/`false`/`null`. The only confirmation pattern — no raw `AlertDialog`. |
| `DSBottomNav` | `ds_bottom_nav.dart` | Floating pill nav. `DSBottomNavItem(icon, label)` per tab; `accentSuccessSoft` selection chip; `surfaceCardDim` track. |
| `CatAvatar` | `cat_avatar.dart` | Circular cat photo or `Icons.pets` fallback on `tintLavender` disc. Default 56px; takes `size`. |
| `MascotSpeechBubble` | `mascot_speech_bubble.dart` | Mascot illustration + speech bubble with `CustomPainter` tail. Used by every cat-create wizard step. |
| `LineChartCard` | `line_chart_card.dart` | Two-line chart (your line vs theirs) inside a `DSCard`. Phase C0. |
| `DSShimmer` / `ShimmerBone` / `ShimmerCircle` | `ds_shimmer.dart` | Loading-skeleton primitives on `shimmer`. `DSShimmer` wraps a bone subtree in the sweep (base `tintAsh`, highlight `surfaceCard`, 1200ms); `ShimmerBone` is a rounded block, `ShimmerCircle` a disc. Place real white `DSCard`s outside the wrapper, bones inside, so cards keep their surface while bones shimmer. |
| `DSAppBar` | `ds_app_bar.dart` | The extracted header (see §8c). `DSAppBar.tab(title, [trailing])` — large `displayLg` title + optional trailing icon, for tab pages. `DSAppBar.modal(onBack, [title], [actions])` — leading 28px chevron-back + optional centered `headlineMd` title + trailing actions. Private `_` constructor: use the factories. |
| `DSHaptics` | `ds_haptics.dart` | Centralized haptics so intensity is tuned in one place. `DSHaptics.selection()` (light tick — picking an option from a list/grid/chip set) and `DSHaptics.tap()` (soft impact — primary CTAs). Call these, never `HapticFeedback` directly. |
| `DSSparkleDecor` / `DSDecorItem` | `ds_sparkle_decor.dart` | Scattered decorative stars painted behind content via `_SparklePainter`. Each `DSDecorItem` positions + tints one star from the star palette (§2). |
| `ProductRowSkeleton` / `ProductListSkeleton` | `skeletons/product_list_skeleton.dart` | Loading skeleton mirroring `ProductRowCard` / `CatSummaryCard` (thumb + 2 lines + pill; `circularThumb` for cat avatars). Used by Search results/pagination, Product Listing, Saved Products, Scan History, Cat Listing. Replaces the old `AppLoadingWidget` spinner on content lists. |

### 8b. Feature-bundled but reused across screens

| Component | File | Shape |
|---|---|---|
| `ProductRowCard` | `lib/features/search_products/presentation/widgets/product_row_card.dart` | 64×64 thumb (or `tintLavender` placeholder) + name + brand + soft score pill + chevron. Used by Search results AND Product Listing. |
| `SearchTextField` | `lib/features/search_products/presentation/widgets/search_text_field.dart` | White pill input, `e1` shadow, search icon prefix. Two modes: **editable** (`controller` + `onChanged` + `autofocus`) on the pushed Search page, and **read-only affordance** (`readOnly: true` + `onTap`, no controller) as the search bar at the top of Home, which pushes `SearchRoute`. |
| `RingScore` | `lib/features/product_detail/presentation/widgets/ring_score.dart` | Circular ring score: `CircularProgressIndicator(value)` + centered number. Color buckets (green / amber / coral) follow `ProductRatingColor`. Used on product analysis card and per-cat verdict cards. |
| `LitterListRow` | `lib/features/litter_detail/presentation/widgets/litter_list_row.dart` | 56×56 thumb (or `HatchedPlaceholder`) + name + brand + soft score pill. Used by BOTH the Saved-products and Scan-history lists, which is why it is one widget rather than the two near-copies the food rows are. The score pill is hidden when `dataUnavailable` — "0/100" reads as a damning grade, not as "no data". |
| `HatchedPlaceholder` | `lib/features/product_detail/presentation/widgets/hatched_placeholder.dart` | 45° hatch `CustomPainter` + "PRODUCT" tag corner. Hero fallback when `imageUrl` is null. |
| `AnalysisChipRow` | `lib/features/product_detail/presentation/widgets/analysis_chip_row.dart` | Wrapping pill chips: success (`+ ...` green) / caution (`! ...` amber). Truncates to 3 pros + 1 con. |
| Per-screen skeletons | `ProductDetailSkeleton`, `CatDetailSkeleton`, `ProfileSkeleton`, `SearchDiscoverSkeleton`, `HomeSkeleton`, `PaywallSkeleton` (each in its feature's `widgets/`) | Layout-matched loading skeletons built from `DSShimmer` + bones, mirroring each screen's loaded body. Replace the old full-screen `AppLoadingWidget`. `HomeSkeleton` covers the dashboard load only — the 4-step scan animation (`HomeLoadingWidget`) now fires solely for a real scan (`HomeScanningState`). `PaywallSkeleton` paints on white (`surfaceCard`) to match the loaded paywall (no mint flash). `AppLoadingWidget` (now a `MascotIllustration`, no GIF) is retained only for the product-detail cat-assessment `FutureBuilder`. |

### 8c. App-shell layout rules

Patterns shared across the post-onboarding app (`MainRoute`).

**The nav has four slots over three tabs.** The tabs are **Home · Recipes · Profile**
(`AutoTabsRouter routes:` in `lib/presentation/main/main_page.dart:16`); the nav renders a fourth
slot, **Scan**, between Home and Recipes. Scan is an *action*, not a tab — it pushes the
root-level `ScannerRoute`. `bottom_nav_bar.dart` owns the mapping (`_slotToTab` / `_tabToSlot`,
with `-1` marking the action slot) and passes a *slot* index as `activeIndex`, so the scan slot
can never equal it and never highlights. `DSBottomNav` itself stays dumb.

Tapping Scan first switches to the Home tab, then pushes the scanner: `HomeBloc` emits
`HomeScanningState` after capture, and the scan theater only paints while Home is the active tab.

⚠️ **Tab identity is duplicated in three places that must stay in sync**: `main_page.dart:16`,
the `MainRoute` `children:` in `lib/config/routes/router.dart`, and `_tabScreenNames` +
the two mapping tables in `lib/features/bottom_navigation_bar/bottom_nav_bar.dart`.

Search and Cats are *not* tabs — Search is a pushed route reached from Home's search bar; Cats is
reached from Home and Profile. All three tabs use `pageBackground` — none of them paints its own; the Home tab used to carry a `DSGradients.homeBackground` wash, now removed in favour of the flat shell colour.

`MainPage` is `Scaffold(backgroundColor: DSColors.pageBackground)` with the nav floating in a
**`Stack`**, not a transparent scaffold with `extendBody`. Both details are load-bearing and
commented in the source:

- **The scaffold is opaque on purpose.** `AutoTabsRouter` cross-fades between tabs, and
  mid-fade both pages are partially transparent — a transparent `Scaffold` lets the black
  window show through as a **black blink**. `pageBackground` matches the Recipes/Profile
  scaffolds and the nav fade gradient.
- **The nav floats in a `Stack`** rather than occupying the `bottomNavigationBar` slot, so
  each tab paints full-bleed to the bottom edge. A soft gradient fade (`bottomInset + 120`)
  sits behind the pill so scrolling content dissolves into the tint instead of being clipped
  by a solid bar — mirroring the onboarding floating-CTA fade.

Don't set per-page Scaffold backgrounds inside the tab pages — the shell handles it. Modal
routes outside the tab shell (`SearchRoute`, `ProductDetailRoute`, `ProductListingRoute`,
`CatDetailRoute`, `CreateCatRoute`, `SavedProductsRoute`, `ScanHistoryRoute`,
`PaywallRoute`) set their own `pageBackground` bg directly, since they're not under `MainPage`.

**Inline header pattern.** `TopAppBar` was retired; every tab and modal renders an inline header with one of two shapes:

- **Tab pages** (Recipes, Profile): `Row(displayLg + trailing icon)` with `~24` horizontal padding. Home leads with a read-only `SearchTextField` instead of a title; the pushed Search page uses the modal header and adds an autofocused `SearchTextField` below it.
- **Modal pages** (Cat Detail, Product Listing, Product Detail, Saved Products, Scan History, Health Record): leading 28px `Icons.chevron_left` `IconButton`, optional centered title (`headlineMd`), optional trailing action icons. Product Detail is the only screen using circular white-disc action buttons (bookmark + ⋯) — these may graduate into `DSCircleIconButton` if a second use appears.

**This was extracted — use `DSAppBar`** (`ds_app_bar.dart`, §8a): `DSAppBar.tab()` for the
first shape, `DSAppBar.modal()` for the second. Don't hand-roll a new header row.

**Bottom inset for floating nav.** Any scroll surface inside a tab page (lists, dashboards) needs a bottom padding of `MediaQuery.of(context).padding.bottom + ~96` so the last item clears the floating-nav pill. Modal pages don't need this — they're full-screen with no nav.

---

## 9. Onboarding flow (new YuCat sequence)

Triggered when `SharedPreferences['onboarding_completed'] != true`.

> **`lib/features/onboarding/README.md` is the source of truth for this flow** — the phase
> machine, the cascade, the analytics contracts and the traps. This section is the design
> view: what each beat looks like and which tokens it uses.
>
> The A0–E0 lettering used by earlier revisions of this doc is gone. The canonical sequence
> is the **`OnBoardingPhase` enum** in `lib/features/onboarding/bloc/onboarding_state.dart`.

### The 12 phases (single PageView, driven by the bloc)

| # | Phase | Widget | Notes |
|---|---|---|---|
| 0 | `welcome` | `welcome_screen.dart` | |
| 1 | `scanDemo` | `scan_demo_screen.dart` | |
| 2 | `attribution` | `attribution_screen.dart` | "How did you hear about us" → written to a Mixpanel People property |
| 3 | `proofChart` | `proof_chart_screen.dart` | Localized Lottie graph; pre-warmed in `didChangeDependencies` so it doesn't decode on the slide-in frame (visible jank) |
| 4 | `whyYucat` | `why_yucat_screen.dart` | `DSGradients.onboardingWhyYucat` |
| 5 | `nutritionFact` | `nutrition_fact_screen.dart` | |
| 6 | `profileIntro` | `profile_intro_screen.dart` | |
| 7 | `profileName` | `profile_name_screen.dart` | Collects the cat name → **seeds the wizard** |
| 8 | `rating` | `rating_screen.dart` | Fires the native App Store review modal — see the warning below |
| 9 | `notifPrimer` | `notif_primer_screen.dart` | **Mock** — previews the value of alerts, requests no permission |
| 10 | `reminders` | `reminders_screen.dart` | The **real** OS push prompt (iOS only). Reminder-type selections are *not* persisted |
| 11 | `healthIntro` | `health_intro_screen.dart` | CTA fires `OnBoardingCompletedEvent` → leaves the bloc (below) |

> ⚠️ **The enum ordinal is an analytics contract.** `_phaseIndex` is
> `OnBoardingPhase.values.indexOf(phase)`, emitted as `step_index` on `Onboarding Step Viewed`
> and used to build the Mixpanel onboarding funnel. **Reordering or inserting a phase
> silently renumbers every historical funnel step.**

> ⚠️ **`rating_screen` bypasses `ReviewPromptService`.** It calls
> `InAppReview.requestReview()` directly, so every new user spends one of Apple's 3-per-365
> review modals during onboarding — outside the gate (`_minScansBeforeFirstPrompt = 5`,
> `_minDaysBetweenPrompts = 90`) that exists to avoid exactly that. There's also no
> completion callback for the modal, so the screen hard-waits 3 seconds before advancing.

### After `healthIntro` — the cascade leaves the bloc

The last four beats are a **router push-chain with callbacks**, not bloc phases. This is the
most expensive part of the flow to reconstruct from code, because no single file shows it:

```
healthIntro CTA → OnBoardingCompletedEvent
  └─ push CreateCatRoute(seededName, onCreated:)      ← the 12-step wizard (§10)
       └─ onCreated: sets onboarding_completed = true  ← NOTE: here, not at the end
            ├─ if !RemoteConfigService.onboardingScanEnabled → OnBoardingFinalizedEvent
            └─ else push CurrentFoodRoute(summary, onStart:)   ← scan your current food
                 └─ replace(ResultRoute)                        ← verdict + locked picks
                      └─ onStart: OnBoardingFinalizedEvent
                           └─ paywall (non-dismissible) → replaceAll(MainRoute → HomeRoute)
```

Three consequences worth knowing:

1. **`onboarding_completed` is written when the cat is created**, before the scan, result
   screen and paywall. A user who quits on the result screen is "onboarded" and meets the
   *splash* paywall gate on next launch instead of resuming onboarding.
2. **`onboarding_scan_enabled` is a live Remote Config kill switch** (default `true`,
   fail-open). Flipping it in the Firebase console skips the scan + result beats entirely for
   new sessions, with no build.
3. `replaceAll` — not `replace` — with the **Home** tab explicitly activated, because the
   stack still holds onboarding → wizard → result underneath.

### Backgrounds

Several beats use dedicated gradients rather than flat tints — see `DSGradients` in §2:
`onboardingWhyYucat`, `onboardingProofChart`, `onboardingHealthIntro`, `onboardingCurrentFood`,
`onboardingSuccess`, `onboardingReminders`, `onboardingNotifPrimer`.

---

## 10. Cat-create reuse (two contexts, one widget set)

The **12** step widgets and `cat_create_bloc` are shared. Only the parent shell differs.

> **`lib/features/cat_create/README.md` owns the wizard** — the step table, the analytics
> contract, the magic numbers, the bloc's subtleties. **Do not restate the step order here**;
> it was previously duplicated in three places and drifted out of sync in all of them. This
> section covers the design side only: shells and chrome.

| Context | Trigger | Shell behavior |
|---|---|---|
| First-time user | Onboarding cascade (§9) | Name is seeded from `profileName`, so the flow **starts at step 1** and the progress bar is rebased to 11 steps. CTA "Create profile". `onCreated` pushes the next screen *over* the wizard (forward slide) instead of popping. |
| Adding / editing a cat | "Add cat" / "Edit" CTA | Modal route + `WizardStepShell`, all 12 steps. Close (×) instead of back on the first step. CTA "Save changes" in edit mode. Pops with a `CatSummary`. |

Chrome rules that belong to the design system:

- Every step renders inside **`WizardStepShell`** — top nav (× / back + progress bar), content,
  sticky CTA. Modes: bottom-anchored (default) or `floatingNext` overlay (used by the
  HealthConditions and Breed steps).
- `altCtaLabel` carries the secondary action — "None of these" on HealthConditions, skip on
  ProfilePhoto.
- The two **interstitial** steps hide the progress bar (`showProgress: !isFactStep`) but stay
  in the denominator, so the bar reads 5/12 → (hidden) → 7/12. They use a full-bleed gradient
  backdrop (`DSGradients.catCreateBackground` for the water beat) rather than the usual white
  card over tint.
- Every step uses `MascotSpeechBubble` for its prompt.

> `lib/services/cat_tracking_service.dart` used to gate this at `_maxFreeCats = 1`. The app is
> now a hard paywall with no free tier — **`canCreateCat` has no callers**. Cat creation is
> unconditional.

---

## 11. Implementation phases

### Shipped

1. ✅ **Token foundation** — `lib/config/themes/theme.dart` carries sections 2–7 above; Bricolage Grotesque bundled, DM Sans via `google_fonts`.
2. ✅ **Component library** — see §8 for shipped components.
3. ✅ **`WizardStepShell` extraction** — the 12 cat-create step widgets render inside the shell; standalone "add cat" flow + onboarding flow share the same widgets.
4. ✅ **Onboarding rebuild** — the 12-phase flow plus the post-wizard cascade (§9).
5. ✅ **Post-onboarding redesign** — Home/Scanner (B3), Cat listing (B4), Cat detail (B5), Search (B6), Product listing (B7), Product detail v1+v2 (B8/B12), Profile (B9), Bottom nav (B2), Empty/Loading/Error states (B11).
6. ✅ **B10 — custom paywall UI** on top of `purchases_flutter` (`RevenueCatUI.presentPaywall()` is intentionally not used). See `lib/features/paywall/README.md`.
7. ✅ **Push + rating** — OneSignal (iOS) and `in_app_review`; see §12 items 7–8.
8. ✅ **Localization** — see §13.

### Outstanding

- **Code hygiene sweep** — pre-existing `flutter analyze` warnings.
- **Visual QA pass** — iOS-sim review of the post-onboarding tabs. (This was originally a
  side-by-side against the BitePal screenshots; those are gone, so it's now a self-review
  against §2–§8.)
- **`DSCircleIconButton`** — extract if a second call site for Product Detail's circular white-disc action buttons appears (§8c).

---

## 12. Open decisions

### Resolved

1. ~~**Display typeface**~~ — **Bricolage Grotesque** (bundled variable font, wght 800 / wdth 75). Sora was the original pick and was replaced before launch.
2. ~~**Body typeface**~~ — **DM Sans** via `google_fonts`. Poppins was the original pick and was replaced.
3. ~~**Selection accent**~~ — **Green** (`accentSuccess #36C078`) for selection ✓; coral (`coralAccent #FF7A59`) reserved for emphasis (chips, slider, "BEST VALUE" tag).
4. ~~**Social-proof stat (C0)**~~ — **APOP** (Association for Pet Obesity Prevention) — "61% of US cats are overweight or obese". Sourced + linked to `petobesityprevention.org`.
5. ~~**Domain pitch source (C2)**~~ — **WSAVA Global Nutrition Guidelines** — linked to `wsava.org/global-guidelines/global-nutrition-guidelines/`. Editorial copy points at the guidelines rather than fabricating a direct quote.
6. ~~**Cat illustration style**~~ — **Cat-mascot SVGs** ship today. Loading / empty / error states render through `MascotIllustration` (cat SVG + tinted halo + twinkling stars, native bob animation); the home scan loader composes its own mascot scene. The legacy `assets/images/Illustrations/*.gif` were removed.
7. ~~**Push notifications**~~ — **Shipped** (this reversed the earlier "deferred" call). OneSignal (`onesignal_flutter`) is wired via `lib/services/notification_service.dart`, **iOS only**, and deliberately does *not* prompt at init — the permission ask lives on the onboarding `reminders` screen. The `notifPrimer` screen before it is a mock and requests nothing. See **`docs/onesignal.md`** for the tag schema, the drop-off Segments, and why the late permission ask limits reach.
8. ~~**App Store rating ask**~~ — **Shipped**, in two places: the onboarding `rating` screen (direct, ungated) and `ReviewPromptService` (gated, `post_scan`). See the warning in §9.

### Still open

_None._

---

## 13. Localization

Every user-facing string goes through `gen_l10n`. There are **6 locales** — `en` (template),
`de`, `es`, `fr`, `hu`, `pt` — at **621 keys each**, currently in full parity.

- `l10n.yaml` → `arb-dir: lib/l10n`, template `app_en.arb`, output class `AppLocalizations`,
  **`nullable-getter: false`** (so `AppLocalizations.of(context)` is non-null — delegates are
  always wired in `main.dart`).
- `pubspec.yaml` has `generate: true`, so the delegates regenerate on build. The generated
  `app_localizations*.dart` files are **committed** under `lib/l10n/`.
- Adding a string means adding it to **all six** ARB files, not just `app_en.arb`.

### Localized art

`lib/presentation/utils/localized_asset.dart` resolves per-locale assets with the
`<base>-<lang>.<ext>` scheme, because Flutter has no built-in per-locale asset resolution:

```dart
localizedAssetPath(context, 'assets/images/onboarding-cards', 'svg')
// → assets/images/onboarding-cards-fr.svg under a French locale
```

Anything outside the `available` set falls back to `-en`. The fallback is deliberate:
`SvgPicture.asset` has no `errorBuilder`, so referencing a missing file would crash.

⚠️ **The `available` default is stale — `{'en', 'es', 'fr', 'hu'}`, missing `de` and `pt`.**
It happens to be harmless today because **all four call sites override it** with the full
six-locale set (`onboarding_page.dart`, `scan_demo_screen.dart`, `why_yucat_screen.dart`,
`proof_chart_screen.dart`), and all three localized asset families ship in all six locales.
But a new call site that relies on the default will silently serve English art to German and
Portuguese users. Either pass the set explicitly or fix the default.
