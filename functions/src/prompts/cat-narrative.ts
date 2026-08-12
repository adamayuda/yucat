import {CANONICAL_LANGUAGE, languageName, normalizeLanguage} from "./languages";
/* eslint-disable max-len */
/**
 * Prompts for the onboarding "personalized narrative" step.
 *
 * Given a freshly created cat profile plus the structured dietary tips derived
 * on-device (the `recommendDiet` rule engine), Haiku writes a short, warm note
 * for the owner AND a forward-looking "~2 weeks" outlook. The profile, tips,
 * condition care-notes, and notable combos ground the prose so the model speaks
 * to THIS cat without inventing claims. Output shape is enforced by the
 * `submit_narrative` tool schema in anthropic.service.ts.
 */

export interface DietTip {
  nutrient: string;
  direction: "more" | "less";
}

export interface CatNarrativeInput {
  name: string;
  lifeStage?: string; // kitten / adult / senior
  breed?: string;
  gender?: string;
  bodyCondition?: string; // underweight / normal / overweight / obese
  activityLevel?: string; // low / medium / high
  neuteredStatus?: string; // neutered / intact / pregnant / lactating
  coatType?: string; // short_hair / long_hair / hairless
  healthConditions?: string[];
  tips: DietTip[];
  locale?: string; // any code in prompts/languages.ts
}

// Lay-level, vet-safe framing for each wizard condition, so the model can
// acknowledge it accurately without diagnosing or prescribing.
const CARE_NOTES: Record<string, string> = {
  urinary_issues:
    "prone to urinary/bladder issues — hydration and urinary-friendly food help",
  kidney_disease:
    "kidney disease — gentler protein and controlled phosphorus ease the kidneys",
  sensitive_stomach:
    "a sensitive stomach — gentle, highly digestible food sits better",
  skin_allergies:
    "skin sensitivity — omega-3s help soothe the skin and coat",
  food_allergies:
    "food allergies — novel or limited-ingredient proteins avoid triggers",
  diabetes:
    "diabetes — lower-carb, higher-protein food helps keep blood sugar steady",
  dental_problems:
    "dental trouble — softer, moisture-rich food is easier to eat",
  hairball_issues:
    "hairballs — extra fiber and omega-3s help them pass naturally",
  heart_condition:
    "a heart condition — omega-3s and taurine support heart health and lower sodium eases the load (food supports, it does not replace vet care)",
  joint_issues:
    "joint or mobility issues — omega-3s help keep joints comfortable",
};

function deriveCombos(input: CatNarrativeInput): string[] {
  const combos: string[] = [];
  const body = (input.bodyCondition ?? "").toLowerCase();
  const activity = (input.activityLevel ?? "").toLowerCase();
  const stage = (input.lifeStage ?? "").toLowerCase();
  const neuter = (input.neuteredStatus ?? "").toLowerCase();
  const conditions = input.healthConditions ?? [];

  if ((body === "overweight" || body === "obese") && activity === "high") {
    combos.push(
      "energetic but carrying a little extra weight — balance keeping them active with gentle weight management"
    );
  }
  if (body === "underweight") {
    combos.push("could use help reaching a healthier weight");
  }
  if (conditions.length >= 2) {
    combos.push("managing more than one health need, so a balanced approach matters");
  }
  if (stage === "senior" &&
    (conditions.includes("kidney_disease") || conditions.includes("heart_condition"))) {
    combos.push("an older cat whose heart and kidneys deserve gentle, steady support");
  }
  if (neuter === "pregnant" || neuter === "lactating") {
    combos.push("expecting or nursing, with higher energy and protein needs right now");
  }
  return combos;
}

export function generateCatNarrativeSystemPrompt(): string {
  return `
You are a warm, knowledgeable companion-animal nutrition writer for a cat-care app.
You write to an owner who has just created their cat's profile, right before they
start using the app. Make it feel written specifically for THIS cat.

Produce two fields via the submit_narrative tool:
1. "narrative" — 2 to 4 sentences, about 50 words. Address the owner ("you") and
   name the cat. Acknowledge EACH listed health condition by name, reflect the
   breed and any notable tension (e.g. energetic but overweight), and weave the
   dietary focus areas in as natural, gentle guidance — never a mechanical list.
   Warm and encouraging, never clinical. End forward-looking: empower the owner
   for the journey ahead and gently nudge them to use the app to find food that
   fits the cat (the app's next step is scanning a product). Do NOT praise their
   current feeding — you don't know what the cat eats.
2. "outlook" — ONE sentence, about 25 words, looking forward. Tie a roughly
   two-week horizon to what good food genuinely shifts: energy, coat shine,
   healthy weight, hydration, digestion. Use "may start to notice" / "could see".

You MAY draw on well-established, lay-level knowledge about the breed and the
listed conditions. You must NOT:
- invent specific numbers, percentages, brands, or product names;
- diagnose, prescribe, or give medical instructions;
- claim any medical CONDITION will be cured, healed, fixed, reversed, or improve
  on a timeline — for conditions, say you are helping "support" their health;
- guarantee outcomes — keep the outlook gentle and conditional on consistent,
  suitable food;
- praise or evaluate the cat's CURRENT diet or feeding — you do NOT know what the
  cat currently eats. Never say things like "you're already doing great" or
  "you're giving them exactly what they need." Frame everything as guidance for
  what to aim for going forward.

Write everything in the requested language. Output ONLY by calling submit_narrative.
`.trim();
}

export function generateCatNarrativeUserPrompt(input: CatNarrativeInput): string {
  const language = languageName(normalizeLanguage(input.locale) ?? CANONICAL_LANGUAGE);

  const profileLines: string[] = [`name: "${input.name}"`];
  if (input.lifeStage) profileLines.push(`life stage: ${input.lifeStage}`);
  if (input.breed) profileLines.push(`breed: ${input.breed}`);
  if (input.gender) profileLines.push(`gender: ${input.gender}`);
  if (input.bodyCondition) profileLines.push(`body condition: ${input.bodyCondition}`);
  if (input.activityLevel) profileLines.push(`activity level: ${input.activityLevel}`);
  if (input.neuteredStatus) profileLines.push(`neutered status: ${input.neuteredStatus}`);
  if (input.coatType) profileLines.push(`coat: ${input.coatType}`);

  const conditions = input.healthConditions ?? [];
  const careNoteLines = conditions.length > 0 ?
    conditions
      .map((c) => `- ${CARE_NOTES[c] ?? c.replace(/_/g, " ")}`)
      .join("\n") :
    "- none reported";

  const combos = deriveCombos(input);
  const comboLines = combos.length > 0 ?
    combos.map((c) => `- ${c}`).join("\n") :
    "- (nothing unusual — a healthy profile to keep up)";

  const tipLines = input.tips.length > 0 ?
    input.tips
      .map((t) => `- ${t.direction} ${t.nutrient}`)
      .join("\n") :
    "- (no specific adjustments; balanced nutrition and hydration)";

  return `
Write the note in ${language}.

Cat profile:
${profileLines.join("\n")}

Health conditions to acknowledge (with lay context):
${careNoteLines}

Notable points about this cat:
${comboLines}

Dietary focus areas (from the app's nutrition engine):
${tipLines}

Call submit_narrative with both "narrative" and "outlook".
`.trim();
}
