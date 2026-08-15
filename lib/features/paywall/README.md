# Paywall

Everything about subscription gating in YuCat: the UI, the bloc, trial detection,
store configuration, and how to change any of it.

> **Status:** the app code is trial-ready and shipped-ready. The **App Store
> configuration is not done yet** — the annual product still carries the old
> pay-up-front intro offer, not a free trial. See [Store configuration](#store-configuration)
> for the migration and why the ordering matters.

---

## 1. What it is

YuCat is a **hard paywall with no free tier**. There is no trial-limited,
scan-limited, or feature-limited mode — a user either has an active entitlement or
cannot use the app at all. Every active user is therefore a subscriber.

The paywall offers **one plan**: annual, entered through a **3-day free trial**.

There is **no plan card** — with a single plan there is nothing to pick, so the
screen goes straight from the hero into the value props, and the terms live in the
sticky footer:

```
      ✓ No payment due now
  [ Redeem 3 days for $0.00 ]
  3 days free, then $24.99/year.
         Cancel anytime.
```

The CTA names the zero price outright rather than saying "free" — concrete beats
abstract at the moment of commitment — and "No payment due now" answers the one
objection that actually stops people here. Both appear **only** when a trial is
being offered.

A user who isn't trial-eligible (they've used one before) sees no "No payment due
now" line, the CTA "Let's get started", and "$24.99/year. Cancel anytime."

---

## 2. Where it's enforced

Only **two** places in the entire app. Past them, every feature is open — there
are no per-feature entitlement checks anywhere in `lib/features/`.

| Gate | File | Condition |
|---|---|---|
| End of onboarding | `onboarding_bloc.dart` `_onOnBoardingFinalizedEvent` | Always, after the cat wizard completes |
| Boot | `splash_bloc.dart` `_onSplashInitialEvent` | `onboarding_completed == true` **and** no active entitlement |

Both push `PaywallRoute(dismissible: false, trigger: …)`.

**A trial counts as subscribed.** RevenueCat sets `entitlement.isActive == true`
for the whole trial period (`periodType == PeriodType.trial`), and
`SubscriptionRepositoryImpl` checks only `isActive`. This is why introducing the
trial required **zero changes** to either gate.

### How "non-dismissible" is enforced

Three mechanisms, all keyed off `dismissible: false`:

1. `PopScope(canPop: false)` in `paywall_page.dart` — blocks system back and the
   iOS edge swipe.
2. The close chip in `_Hero` is only built when `onClose != null`.
3. The only exits are `PaywallSuccessState` / `PaywallAlreadySubscribedState`,
   both of which pop.

Escape hatches: a `kDebugMode`-only skip button, and `kTestBuildSkipPaywall` in
`lib/config/test_flags.dart` (currently `false`) which bypasses both gates.

> **Note:** both call sites `await` the `push` but **ignore its return value**,
> then navigate onward unconditionally. The gate holds only because the paywall
> never pops itself in a release build unless a purchase or restore succeeded.

---

## 3. File map

```
lib/features/paywall/
├── README.md                      this document
├── paywall_page.dart              @RoutePage; PopScope, BlocConsumer, SnackBars
├── bloc/
│   ├── paywall_bloc.dart          offerings, eligibility, purchase, restore
│   ├── paywall_event.dart         5 events
│   └── paywall_state.dart         6 states
├── utils/
│   ├── trial_info.dart            cross-platform trial detection  ← the subtle bit
│   └── paywall_format.dart        price/period/CTA string helpers
└── widgets/
    ├── paywall_loaded_widget.dart hero, value props, CTA, disclosures, legal links
    ├── paywall_package_row.dart   the plan card — **not rendered** (see §11)
    ├── paywall_value_props.dart   6 feature rows
    ├── paywall_testimonials.dart  carousel (placeholder testimonials)
    ├── paywall_skeleton.dart      shimmer while offerings load
    └── paywall_error_widget.dart  fatal load error + Try again
```

Related, outside the feature:

| Path | Role |
|---|---|
| `lib/core/subscription/` | `SubscriptionRepository`, `HasActiveSubscriptionUseCase` |
| `lib/config/routes/router.dart` | `PaywallRoute` — `CustomRoute`, `/paywall`, `fullscreenDialog`, `opaque: false`, `slideBottom` |
| `lib/main.dart` | `Purchases.configure`, app-level `BlocProvider(PaywallBloc)` |
| ~~`test/features/paywall/trial_info_test.dart`~~ | **Removed.** There is no `test/` directory in the repo — see §9 |

**Bloc lifetime gotcha:** `PaywallBloc` is registered as a *factory* in
`service_locator.dart`, but `main.dart:140` wraps the app in a single
`BlocProvider`. `PaywallPage.initState` does `context.read<PaywallBloc>()`, so
**one long-lived instance serves both gates** for the whole app session — it is
not recreated per presentation.

---

## 4. Runtime flow

```
PaywallInitialEvent(trigger)
        │
        ├─ hasActiveSubscription()? ──► PaywallAlreadySubscribedState ──► pop(true)
        │
        ├─ Purchases.getOfferings()
        │     ├─ PlatformException ────► PaywallErrorState(couldNotLoadPlans)
        │     └─ current == null / empty ► PaywallErrorState(noPlansAvailable)
        │
        ├─ filter availablePackages to PackageType.annual
        │     └─ empty? fall back to [availablePackages.first]
        │
        ├─ _eligibleTrialFor(selected)  ──► TrialInfo?
        │
        └─► PaywallLoadedState(offering, packages, selected, eligibleTrial)
                 │
                 ├─ PaywallPurchaseEvent
                 │     Purchases.purchase(PurchaseParams.package(…))
                 │     Purchases.syncPurchases()
                 │     hasActiveSubscription(forceRefresh: true)
                 │       ├─ true  ► PaywallSuccessState(true)  ► pop(true)
                 │       └─ false ► transient purchaseNotComplete
                 │
                 ├─ PaywallRestoreEvent   (same shape)
                 └─ PaywallDismissEvent   ► PaywallSuccessState(false) ► pop(false)
```

### States

`PaywallInitialState` · `PaywallLoadingState` · `PaywallLoadedState` ·
`PaywallSuccessState` · `PaywallErrorState` · `PaywallAlreadySubscribedState`

`PaywallLoadedState` carries `currentOffering`, `packages`, `selectedPackage`,
`isPurchasing`, **`eligibleTrial`**, `transientError`, `errorTick`.

- `copyWith` deliberately **cannot** change `eligibleTrial`, `packages`, or
  `currentOffering` — they're resolved once at load.
- `transientError` is one-shot: it clears unless explicitly passed.
- `errorTick` increments so `BlocListener` re-fires a SnackBar even when the
  error kind repeats.
- `props` compares `eligibleTrial?.days`, not the object — `TrialInfo` isn't
  `Equatable`.

### Events

`PaywallInitialEvent(trigger)` · `PaywallPackageSelectedEvent(package)` ·
`PaywallPurchaseEvent` · `PaywallRestoreEvent` · `PaywallDismissEvent`

`PaywallPackageSelectedEvent` is unreachable with a single plan, but is kept
wired so restoring a second plan needs no bloc changes.

---

## 5. Trial detection and eligibility

This is the part with real subtlety. Two questions, answered separately:

1. **Does the product offer a trial?** → `trialInfoFor(Package)` in `trial_info.dart`
2. **Can *this user* have it?** → `_eligibleTrialFor(Package)` in `paywall_bloc.dart`

Only when both say yes does `PaywallLoadedState.eligibleTrial` become non-null,
and **every** trial claim in the UI — badge, CTA, disclosure — is gated on it.

### Detection: the stores disagree

| | Google Play | StoreKit |
|---|---|---|
| Free trial | `SubscriptionOption.freePhase` | `introductoryPrice` with `price == 0` |
| Discount | `SubscriptionOption.introPhase` | `introductoryPrice` with `price > 0` |

Play models them as distinct fields. **StoreKit does not** — a free trial and a
discounted first period are both just `introductoryPrice`, and the only thing
separating them is whether the price is zero.

```dart
final intro = product.introductoryPrice;
if (intro != null && intro.price <= 0) { … }   // trial
```

That check is why the outgoing pay-up-front first-year offer resolves to *no trial*
rather than a false "FREE" badge, which is what a half-migrated store would
otherwise produce. It **used to be** covered by unit tests — see §9.

Play is checked first (`defaultOption.freePhase`, falling back to scanning
`subscriptionOptions` for a non-prepaid option). Periods normalise to days:
day ×1, week ×7, month ×30, year ×365; `PeriodUnit.unknown` returns null so we
never advertise a length we can't compute. Cycle counts are clamped to 1–12.

`TrialInfo.priceString` carries the store's own formatted zero — `introductoryPrice.priceString`
on StoreKit, `freePhase.price.formatted` on Play — which is what fills the
`Redeem 3 days for $0.00` CTA. Always take it from the store rather than
formatting a zero yourself; currency symbol, placement and decimal separator are
all locale-dependent. Some Play locales return the word "Free" instead of a
number, which still reads correctly in the CTA. If it comes back empty,
`ctaLabelFor` falls back to `paywallCtaStartTrial`.

### Eligibility: iOS asks Apple, Android infers

```dart
if (Platform.isAndroid) return trial;          // Play already filtered
// iOS:
Purchases.checkTrialOrIntroductoryPriceEligibility([id]).timeout(5s)
  → introEligibilityStatusEligible ? trial : null
```

**iOS** — RevenueCat computes StoreKit eligibility. Anything that isn't an
explicit `eligible` (unknown, ineligible, error, timeout) returns null. Fails
closed by design.

**Android** — `checkTrialOrIntroductoryPriceEligibility` **always returns
`unknown` on Android**; the SDK documents this. Fail-closed logic would therefore
mean Android never shows a trial. Instead we rely on Google Play filtering offers
server-side: an offer restricted to new customers simply isn't returned to an
ineligible user, so the *presence* of `freePhase` is the eligibility signal.

> ⚠️ **This makes a Play Console setting load-bearing.** The offer's eligibility
> criteria must be **"New customer acquisition → Never had a subscription to this
> app."** If it's set to "Developer determined", Play returns the offer to
> everyone, the app badges "3 DAYS FREE", and ineligible users are charged
> immediately — bad UX and a Play policy risk.

---

## 6. Store configuration

### App Store Connect

Subscription group **`yucat-subscription-revenuecat`** — ID `21827689`.
All three products live in it:

| Level | Reference name | Product ID | Duration |
|---|---|---|---|
| 1 | Yucat Premium Yearly | `com.adam.yucat.app.pro.yearly` | 1 year |
| 2 | Yucat Premium Monthly | `com.adam.yucat.app.pro.monthly` | 1 month |
| 3 | Yucat Premium Weekly | `com.adam.yucat.app.pro.weekly` | 1 week |

Only **yearly** is surfaced by the app. Monthly and weekly remain published and
continue to bill existing subscribers; they're filtered out client-side.

**Current offer on yearly** (pre-migration): *Pay up front for the first year*,
Jun 12 2026 → No End Date, 175 regions.

#### Eligibility is per *group*, not per product

Apple grants one introductory offer per customer **per subscription group**,
permanently. Because all three products share group `21827689`, anyone who has
consumed *any* intro offer on *any* of them can never receive the 3-day trial.
The trial-eligible pool is effectively "has never subscribed to YuCat at all".

#### The migration, and why order matters

Apple permits only one *active* intro offer per product per territory, so the
trial can't coexist with the pay-up-front offer. But they don't need to overlap —
they can **abut**: end date on one, start date the next day on the other.

The hazard is the **shipped 2.0.4 build**, which predates `trial_info.dart` and
treats any introductory price as a discount:

```dart
final saved = (1 - intro.price / full) * 100;   // (1 - 0/24.99) * 100 = 100
```

With a trial live, 2.0.4 renders **"Limited-time offer · Save 100%"** and a
`$0.00` headline price — it reads as a free year. So:

1. **Leave the pay-up-front offer running.** Ending it early just gives new users a
   worse deal ($24.99 upfront, no offer) for the whole waiting window.
2. **Ship the trial-ready build.** With no trial configured it shows a plain
   $24.99 paywall — same as old builds. Safe to ship at any time.
3. **Once adoption has climbed**, in one sitting: set the pay-up-front offer's
   End Date to that day, then create the trial starting the next day —
   type **Free Trial**, duration **3 Days**, No End Date, same 175 regions.

Adding an intro offer to an already-approved product goes live **without** app
review.

Alternative: if your RevenueCat plan includes **Targeting**, serve builds below
the new version an offering with no trial-bearing product. That removes the
exposure entirely and lets you skip the wait.

### Google Play

Annual base plan → **Offers** → create offer, ID `freetrial-3d`, one **Free
trial** phase of **3 days**, eligibility **"Never had a subscription to this
app"** (see the warning in §5), then **Activate** — Play offers are invisible to
the SDK while in Draft.

### RevenueCat

**There is nothing to configure for the trial itself.** An iOS introductory offer
lives entirely on the App Store product; StoreKit applies it at purchase and
RevenueCat relays it as `storeProduct.introductoryPrice`. There is no offer
object in RevenueCat. Everything below is a *check*.

| What | Value |
|---|---|
| Entitlement | **`yucat pro`** — note the space; hardcoded in `subscription_repository_impl.dart:5` |
| Package | Must use the reserved identifier **`$rc_annual`** |
| Offering | Read as `offerings.current`; its own identifier is never checked |
| iOS SDK key | `appl_RLrrtMqNXWlaNlEXzZQxUcxkJxw` |
| Android SDK key | `goog_RiTqfgyAOTSPvSLQjnBszSTXAKK` |

> ⚠️ **The `$rc_annual` identifier is load-bearing.** RevenueCat derives
> `packageType` from that reserved name, and the bloc filters on
> `packageType == PackageType.annual`. A custom package identifier resolves to
> `PackageType.custom`, the filter finds nothing, and the paywall falls back to
> `availablePackages.first` — potentially the weekly plan.

The app references **no product IDs** — only the entitlement above.

---

## 7. Localization

51 `paywall*` keys across 6 locales (en/de/es/fr/hu/pt). `@key` metadata blocks
live **only** in `app_en.arb`; other locales carry bare keys. Regenerate with
`fvm flutter gen-l10n`.

Trial-related keys:

| Key | English |
|---|---|
| `paywallBadgeFreeTrial` | `{days} DAYS FREE` |
| `paywallCtaRedeemTrial` | `Redeem {days} days for {price}` — primary trial CTA |
| `paywallCtaStartTrial` | `Start {days}-day free trial` — used when the store gave no formatted zero price |
| `paywallCtaUnlockPlus` | `Let's get started` (non-trial fallback) |
| `paywallNoPaymentDue` | `No payment due now` |
| `paywallThenPrice` | `then {price}/{period}` |
| `paywallPerPeriodPrice` | `{price}/{period}` |
| `paywallPeriodSuffixWeekly/Monthly/Annual` | `week` / `month` / `year` |
| `paywallTrialDisclosure` | `{days} days free, then {price}/{period}. Cancel anytime.` |
| `paywallPriceDisclosure` | `{price}/{period}. Cancel anytime.` |
| `paywallAutoRenewDisclosureTrial` | long-form trial→paid conversion terms |
| `paywallAutoRenewDisclosure` | long-form renewal terms, no trial |
| `paywallCancelAnytime` | fallback when a package has no period suffix |
| `paywallRetry` | `Try again` (error screen) |

`{store}` in the disclosures is filled in Dart with `Platform.isIOS ? 'App Store'
: 'Google Play'` — brand names aren't translated.

**Compliance note.** The short line under the CTA carries trial length,
conversion price, billing period and cancellation. App Store guideline 3.1.2 and
Play's subscription policy both expect those at the point of purchase; don't
remove it, and keep the trial length dynamic rather than hardcoding "3".

The five non-English locales are machine-drafted and **have not had a native
review**. This is legally-loaded copy that store reviewers read.

---

## 8. Analytics

Events in `lib/features/analytics/analytics_events.dart`:

| Event | Key properties |
|---|---|
| `Paywall Shown` | `trigger`, `offering`, `trial_eligible`, `trial_days` |
| `Paywall Dismissed` | `cta_tapped`, `time_viewed_seconds` (inline literal, not a constant) |
| `Subscription Completed` | `package_id`, `package_type`, `price`, `currency`, `trigger`, **`is_trial`**, **`trial_days`** |
| `Subscription Restored` | — |
| `Subscription Purchase Failed` | `reason`, `package_type` |
| `Subscription Restore Failed` | `reason`, `error_message` |
| `Plan Selected` | unreachable with a single plan; kept for a future second plan |

`PaywallTrigger` values: `onboarding_complete`, `returning_user`.

`is_trial: true` means **no money moved today**. Downstream revenue reporting has
to separate those from immediate purchases, or day-one revenue looks fabricated.

---

## 9. Testing

**Unit** — ⚠️ **none.** `test/features/paywall/trial_info_test.dart` (11 tests over
`trialInfoFor`, covering both store shapes, the discount-is-not-a-trial case,
prepaid skipping, unknown periods and cycle clamping) **no longer exists** — there
is no `test/` directory in the repo at all. `trialInfoFor` is pure, dependency-free
and needs neither network nor platform channels, so it is the cheapest thing here
to re-cover; restoring that file is the highest-value test in the feature.

**iOS sandbox** — create sandbox testers under Users and Access → Sandbox → Test
Accounts, sign in via *Settings → App Store → Sandbox Account*. Trials and
renewals run at accelerated rates (minutes, not days).

> Introductory-offer eligibility is **permanent per Apple ID per subscription
> group and cannot be reset.** Each tester is one use of the eligible path —
> create several up front.

**iOS StoreKit config file** — fastest loop for *rendering* work: Xcode → New File
→ StoreKit Configuration File, then Scheme → Run → Options. *Debug → StoreKit →
Manage Transactions* resets eligibility instantly. RevenueCat entitlements may
not flip against a local config, so use sandbox for the purchase→entitlement path.

**Android** — license testers, app installed **from Play** on at least an internal
testing track (sideloaded debug builds return no products). The critical test:
reopen the paywall after consuming the trial and confirm the offer vanishes from
`subscriptionOptions` — that validates the whole Android inference in §5.

**Debug logging** — `LogLevel.debug` is enabled *unconditionally* in `main.dart`
(not gated on `kDebugMode`), so product JSON including the intro-price block
prints to the console on `getOfferings()`.

---

## 10. Known gaps

| Gap | Detail |
|---|---|
| No `CustomerInfo` listener | `Purchases.addCustomerInfoUpdateListener` is never registered, and `didChangeAppLifecycleState` doesn't re-check entitlements. A trial expiring mid-session isn't observed until cold launch. |
| RevenueCat identity is unlinked | `appUserID = null` and `Purchases.logIn` is never called, so the RC anonymous ID is never tied to the Firebase UID. Entitlements follow the store account; a reinstalling user must tap **Restore purchases**. Trial abuse via reinstall is *not* possible — Apple/Play enforce eligibility per store account. |
| `SubscriptionRepositoryImpl` fails closed | `getCustomerInfo()` has a 5s timeout and returns `false` on any error, so a paying user offline at boot is held at the paywall. |
| Dead free-tier code | `ScanTrackingService.canPerformScan` and `CatTrackingService.canCreateCat` are never called. Both classes now have **zero live callers** — `ScanTrackingService`'s last one was the scan streak, since removed. Kept so a free tier can be re-enabled. |
| `PaywallError.iosOnly` never emitted | Vestigial; `paywall_error_widget.dart` still maps it. |
| Placeholder social proof | Testimonials and the `4.7` / `1M+` laurel stats are hardcoded, not real data. |

---

## 11. Changing things

**Trial length** — change it in App Store Connect and Play Console only. The app
reads the configured duration and renders `{days}` everywhere; nothing is
hardcoded. Allowed Apple durations: 3 days, 1 week, 2 weeks, 1 month, 2 months,
3 months, 6 months, 1 year.

**Bring back a second plan** — one filter in `PaywallBloc._onInitial`:

```dart
.where((p) => p.packageType == PackageType.annual)
```

Then render `PaywallPackageRow` again in `paywall_loaded_widget.dart` — the widget
is still in the tree, just no longer called — looping over `packages`, re-add a
"BEST VALUE" badge string, and bump the skeleton back to two bones.
`PaywallPackageSelectedEvent` and the `Plan Selected` event are already wired.

**Why the plan card is gone.** With one plan there is nothing to choose, so the
card was a price display rather than a picker (its `onTap` re-selected the package
it was already on). The price and trial terms are still stated **twice** below the
fold — `_Reassurance` directly under the CTA and `_AutoRenewDisclosure` at the end
of the scroll — so the App Store 3.1.2 / Play disclosure requirement is unaffected.
Purchase is unaffected too: `selectedPackage` is set in `PaywallBloc._onInitial`,
never by the card.

**Re-enable a free tier** — the tracking services and their limits are intact; wire
`canPerformScan` / `canCreateCat` back into `HomeBloc` and the cat wizard, and
relax the two gates in §2.

**Remove the hard gate for testing** — `kTestBuildSkipPaywall` in
`lib/config/test_flags.dart`.

---

## 12. History

The paywall previously offered **weekly + annual** with a "Limited-time offer"
promo `Switch` that collapsed the list to a discounted annual plan. That switch,
its shine animation, `PaywallPromoToggledEvent`, the `Paywall Promo Toggled`
event, and the `hasIntroOffer` / `introPriceStringFor` / `renewalLabelFor` /
`introSavingsLabelFor` / `savingsLabelFor` helpers were all removed when the
trial landed — a trial is not a discount, and rendering one as a struck-through
price would misrepresent it.

`PaywallErrorWidget`'s CTA changed from **Close** to **Try again** at the same
time: under a hard gate `PopScope` blocks the pop, so Close left the user on a
dead screen with no way forward.
