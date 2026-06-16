/* eslint-disable max-len */
/**
 * Prompts for the one-off catalog re-score (scripts/rescore-products.ts).
 *
 * Re-grades an already-analyzed product's quality from its stored facts (macros
 * + existing pros/cons) using the shared QUALITY_RUBRIC. No web search — the
 * pros/cons already carry the ingredient facts; we only re-weigh them.
 */
import {QUALITY_RUBRIC} from "./quality-rubric";

export interface RegradeInput {
  name: string;
  brand: string;
  foodType: string;
  protein: number;
  fat: number;
  carbs: number;
  fiber: number;
  moisture: number;
  ash: number;
  pros: string[];
  cons: string[];
}

export function generateRegradeSystemPrompt(): string {
  return `
You are a veterinary nutrition assistant grading the nutritional quality of a cat
food for an average healthy adult cat.

${QUALITY_RUBRIC}

Return only the 0-100 score via the submit_score tool. Do not write free text.
`.trim();
}

export function generateRegradeUserPrompt(p: RegradeInput): string {
  const dm = p.moisture < 100 ? 100 / (100 - p.moisture) : 1;
  const r = (x: number) => Math.round(x * 10) / 10;
  return [
    `Product: "${p.name}" by ${p.brand} (${p.foodType})`,
    `Guaranteed analysis (as-fed %): protein ${p.protein}, fat ${p.fat}, ` +
      `carbs ${p.carbs}, fiber ${p.fiber}, moisture ${p.moisture}, ash ${p.ash}`,
    `On a dry-matter basis: protein ${r(p.protein * dm)}%, carbs ${r(p.carbs * dm)}%`,
    `Known pros: ${p.pros.length ? p.pros.join("; ") : "(none)"}`,
    `Known cons: ${p.cons.length ? p.cons.join("; ") : "(none)"}`,
    "",
    "Grade this product's nutritional quality 0-100 with the rubric. The pros and " +
      "cons above are factual evidence about its ingredients — weigh ingredient-" +
      "quality issues (added sugar, plant/vegetable protein padding, low real-meat " +
      "%, fillers, vague 'derivatives') even when the macro numbers look strong. " +
      "Call submit_score.",
  ].join("\n");
}
