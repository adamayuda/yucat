# Screenshots

Generated PNGs of the onboarding + cat-creation flow, produced by the screenshot
integration test.

## Regenerating

Boot an iOS simulator, then from the repo root:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/onboarding_screenshots_test.dart \
  -d <simulator-id>
```

Find a simulator id with `flutter devices`. The test resets SharedPreferences so
onboarding shows on every run, walks all 20 screens, and writes one PNG per
screen into this directory.

## What gets captured

| File | Screen |
|---|---|
| `01-onboarding-welcome.png` | Welcome |
| `02-onboarding-value-carousel-1.png` | Value carousel — scan |
| `03-onboarding-value-carousel-2.png` | Value carousel — personalized |
| `04-onboarding-value-carousel-3.png` | Value carousel — catalog |
| `05-onboarding-attribution.png` | "How did you hear about us?" |
| `06-onboarding-attribution-details.png` | Influencer name input |
| `07-onboarding-social-proof.png` | Social proof |
| `08-onboarding-why-yucat.png` | Why YuCat works |
| `09-onboarding-domain-pitch.png` | "What's in the bowl matters" |
| `10-onboarding-add-cat-intro.png` | Add-my-cat intro |
| `11-cat-create-name.png` | Wizard — cat name |
| `12-cat-create-photo.png` | Wizard — profile photo |
| `13-cat-create-gender.png` | Wizard — gender |
| `14-cat-create-age.png` | Wizard — age |
| `15-cat-create-activity.png` | Wizard — activity level |
| `16-cat-create-neutered-status.png` | Wizard — neutered status |
| `17-cat-create-coat.png` | Wizard — coat type |
| `18-cat-create-health-conditions.png` | Wizard — health conditions |
| `19-cat-create-breed.png` | Wizard — breed |
| `20-onboarding-success.png` | "You're all set!" success |

Note: each run writes a real cat document to Firestore (the wizard submit is not
mocked).
