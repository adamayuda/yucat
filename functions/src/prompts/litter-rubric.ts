/* eslint-disable max-len */
/**
 * Shared 0-100 cat-litter quality rubric.
 *
 * The counterpart to `quality-rubric.ts`, and the single source of litter
 * scoring truth. The key principle: **litter is graded for the cat first and
 * the owner second.** A litter that a cat refuses to use is a failed litter
 * however convenient it is to clean, so fragrance, texture and dust outrank
 * odour-control marketing.
 *
 * There is deliberately no breed dimension — breed does not change what makes a
 * litter good. The only per-cat adjustments in the app are safety flags driven
 * by age and health conditions, and those live client-side, not here.
 */
export const LITTER_RUBRIC = `
SCORING RUBRIC (0-100) — grade for a typical healthy adult cat in a typical home.

Start around 70 for an adequate, usable litter, then adjust:

Reward (push higher, toward 85-100):
- Fine, soft, sand-like granules — the texture cats naturally prefer to dig in.
- Genuinely low dust (explicitly "99% dust free", "dust free", or an inherently
  low-dust substrate such as tofu, pellets or paper).
- Unscented / fragrance-free.
- Strong clumping that forms hard, intact clumps and allows full waste removal.
- Effective odour control achieved by absorption or a neutralizer (baking soda,
  activated charcoal, plant fibre) rather than by masking with perfume.
- Low tracking (larger or heavier granules, or a substrate that does not stick
  to paws).
- Flushable / biodegradable / renewable substrate — a genuine benefit, but a
  minor one next to what the cat experiences.

Penalize (push lower, toward 30-60):
- Added fragrance or perfume. Cats have far more sensitive noses than people;
  scent is a leading cause of litter-box rejection. This is a real penalty, not
  a footnote.
- High dust — a respiratory irritant for both cat and owner, and the single
  most common complaint about clay litters.
- Coarse, sharp or pellet textures that many cats dislike underfoot (a
  legitimate concern even when the litter performs well otherwise).
- Poor or no clumping in a litter sold as clumping.
- Heavy tracking through the house.
- Odour control that works by masking rather than absorbing.
- Marketing claims with nothing behind them ("advanced odour technology") when
  the substrate and additives do not support them.

Material notes — apply these as context, never as an automatic verdict:
- Sodium-bentonite clumping clay is the performance benchmark for clumping and
  odour control, and is appropriate for most adult cats. It is also the dustiest
  and heaviest common substrate, and it is not biodegradable. Grade a specific
  product on its own dust and clumping claims rather than on the material alone.
- Silica crystal is very low dust and highly absorbent, but does not clump; many
  cats dislike the texture, and it must be stirred and fully replaced.
- Tofu, corn, wheat, wood, paper, walnut and grass litters are lighter,
  biodegradable and usually lower dust. Clumping strength varies widely — judge
  the product, not the category.
- Non-clumping clay is cheap and simple but requires full box changes and
  controls odour poorly. It is not a defect, but it caps the achievable score.

Calibration:
- A scented, high-dust litter with strong clumping → mid (≈ 50-65), never
  "excellent", however good the odour claims are.
- An unscented, low-dust, hard-clumping litter with a natural neutralizer →
  high (≈ 85-100).
- A litter you can confirm exists but for which you found no attribute detail at
  all → score 0 (the "no data" sentinel), never a guessed middling number.
`.trim();
