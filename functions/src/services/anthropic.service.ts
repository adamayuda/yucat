import Anthropic from "@anthropic-ai/sdk";
import * as logger from "firebase-functions/logger";
import {config} from "../config";
import {RETRY_CONFIG} from "../constants";
import {FoodType, Product, ProductModel} from "../models/product";
import {generateIdentificationPrompt} from "../prompts/identify-product";
import {
  generateAnalysisSystemPrompt,
  generateAnalysisUserPrompt,
} from "../prompts/analyze-product";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let anthropicClient: any = null;

function getClient(): Anthropic {
  if (!anthropicClient) {
    if (!config.anthropic.apiKey) {
      throw new Error(
        "ANTHROPIC_API_KEY is not set. Configure via " +
        "`firebase functions:secrets:set ANTHROPIC_API_KEY` and declare " +
        "`secrets: [\"ANTHROPIC_API_KEY\"]` in the onCall runtime options."
      );
    }
    anthropicClient = new Anthropic({apiKey: config.anthropic.apiKey});
  }
  return anthropicClient;
}

const SUPPORTED_MEDIA_TYPES = new Set<string>([
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
]);

type AnthropicMediaType = "image/jpeg" | "image/png" | "image/gif" | "image/webp";

function normalizeMediaType(mimeType: string): AnthropicMediaType {
  if (SUPPORTED_MEDIA_TYPES.has(mimeType)) {
    return mimeType as AnthropicMediaType;
  }
  return "image/jpeg";
}

/**
 * Retries an async operation with exponential backoff on transient failures
 * (5xx, 429). Mirrors the yucat-api Gemini retry pattern.
 */
async function withRetry<T>(
  label: string,
  fn: () => Promise<T>
): Promise<T> {
  let lastError: unknown;
  for (let attempt = 0; attempt <= RETRY_CONFIG.MAX_RETRIES; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      const status = (error as {status?: number})?.status;
      const isRetryable = status === 429 || (status !== undefined && status >= 500);
      const willRetry = isRetryable && attempt < RETRY_CONFIG.MAX_RETRIES;

      logger.warn("Anthropic call failed", {
        label,
        attempt: attempt + 1,
        status: status ?? "unknown",
        willRetry,
        error: error instanceof Error ? error.message : String(error),
        structuredData: true,
      });

      if (!willRetry) {
        break;
      }
      const wait = RETRY_CONFIG.BASE_WAIT_TIME_MS * Math.pow(2, attempt);
      await new Promise((resolve) => setTimeout(resolve, wait));
    }
  }
  throw lastError;
}

export interface ProductIdentification {
  brand: string;
  name: string;
  foodType: FoodType;
}

const FOOD_TYPE_ENUM: FoodType[] = [
  "wet", "dry", "treat", "topper", "supplement",
];

const IDENTIFICATION_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_identification",
    description:
      "Submit the identified cat food product. Call this when the image " +
      "clearly shows a cat food product.",
    input_schema: {
      type: "object",
      required: ["brand", "name", "foodType"],
      properties: {
        brand: {type: "string", description: "Brand name from packaging"},
        name: {
          type: "string",
          description: "Full product name including line, flavor, variant",
        },
        foodType: {type: "string", enum: FOOD_TYPE_ENUM},
      },
    },
  },
  {
    name: "not_cat_food",
    description:
      "Call this if the image is not a cat food product (dog food, " +
      "human food, non-food items, or unrecognizable).",
    input_schema: {type: "object", properties: {}},
  },
];

const ANALYSIS_TOOLS: Anthropic.Tool[] = [
  {
    name: "submit_product",
    description: "Submit the final cat food product analysis.",
    input_schema: {
      type: "object",
      required: [
        "name", "brand", "foodType", "format", "packageSize", "description",
        "protein", "fat", "moisture", "carbs", "fiber", "ash",
        "imageUrl", "score", "pros", "cons",
      ],
      properties: {
        name: {type: "string"},
        brand: {type: "string"},
        foodType: {type: "string", enum: FOOD_TYPE_ENUM},
        format: {
          type: "string",
          description:
            "Short display-friendly format e.g. \"Wet pâté\", \"Dry kibble\", " +
            "\"Crunchy treats\". Title case, max 24 chars.",
        },
        packageSize: {
          type: "string",
          description:
            "Pack size as printed on packaging, e.g. \"85g pouch\", " +
            "\"12 lb bag\", \"6 x 70g multipack\". Empty string if not visible.",
        },
        description: {
          type: "string",
          description:
            "2-3 sentence nutrition-focused summary describing the product " +
            "and its key characteristics for an average healthy adult cat. " +
            "No marketing language.",
        },
        protein: {type: "number", minimum: 0, maximum: 100},
        fat: {type: "number", minimum: 0, maximum: 100},
        moisture: {type: "number", minimum: 0, maximum: 100},
        carbs: {type: "number", minimum: 0, maximum: 100},
        fiber: {type: "number", minimum: 0, maximum: 100},
        ash: {type: "number", minimum: 0, maximum: 100},
        imageUrl: {type: "string"},
        score: {type: "number", minimum: 0, maximum: 100},
        pros: {type: "array", items: {type: "string"}, maxItems: 3},
        cons: {type: "array", items: {type: "string"}, maxItems: 3},
      },
    },
  },
];

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function findToolUse(content: any[], name: string): any | undefined {
  return content.find(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (block: any) => block?.type === "tool_use" && block?.name === name
  );
}

/**
 * Step 1 — Quick identification from the photo. No web search.
 * Returns null if the image is not a cat food product.
 */
export async function identifyProductFromImage(
  imageBase64: string,
  mimeType: string
): Promise<ProductIdentification | null> {
  const mediaType = normalizeMediaType(mimeType);
  const prompt = generateIdentificationPrompt();

  const response = await withRetry("identifyProductFromImage", () =>
    getClient().messages.create({
      model: config.anthropic.model,
      max_tokens: 256,
      temperature: config.anthropic.temperature,
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {type: "base64", media_type: mediaType, data: imageBase64},
            },
            {type: "text", text: prompt},
          ],
        },
      ],
      tools: IDENTIFICATION_TOOLS,
      tool_choice: {type: "any"},
    })
  );

  const submit = findToolUse(response.content, "submit_identification");
  if (submit) {
    const input = submit.input as ProductIdentification;
    logger.info("Product identified", {
      brand: input.brand,
      name: input.name,
      foodType: input.foodType,
      structuredData: true,
    });
    return input;
  }

  const notCatFood = findToolUse(response.content, "not_cat_food");
  if (notCatFood) {
    logger.info("Image classified as non-cat-food", {structuredData: true});
    return null;
  }

  logger.warn("Identification call returned no tool_use", {
    stopReason: response.stop_reason,
    structuredData: true,
  });
  return null;
}

/**
 * Step 2 — Full analysis with Anthropic web_search. Returns a Product on
 * success, or null if the model could not produce a structured answer.
 *
 * web_search_20250305 is a server-side tool — Anthropic resolves searches
 * internally, so we receive a single response with the final submit_product
 * tool_use block (no manual tool-use loop required).
 */
export async function analyzeProductImage(
  imageBase64: string,
  mimeType: string
): Promise<{product: Product | null; rawResponse: string}> {
  const mediaType = normalizeMediaType(mimeType);
  const systemText = generateAnalysisSystemPrompt();
  const userText = generateAnalysisUserPrompt();

  const response = await withRetry("analyzeProductImage", () =>
    getClient().messages.create({
      model: config.anthropic.model,
      max_tokens: 4096,
      temperature: config.anthropic.temperature,
      system: [
        {
          type: "text",
          text: systemText,
          cache_control: {type: "ephemeral"},
        },
      ],
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image",
              source: {type: "base64", media_type: mediaType, data: imageBase64},
            },
            {type: "text", text: userText},
          ],
        },
      ],
      tools: [
        {
          type: "web_search_20250305",
          name: "web_search",
          max_uses: config.anthropic.maxWebSearches,
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } as any,
        ...ANALYSIS_TOOLS,
      ],
      tool_choice: {type: "auto"},
    })
  );

  const submit = findToolUse(response.content, "submit_product");
  if (!submit) {
    logger.warn("analyzeProductImage returned no submit_product", {
      stopReason: response.stop_reason,
      structuredData: true,
    });
    return {product: null, rawResponse: JSON.stringify(response.content)};
  }

  const product = ProductModel.fromObject({
    ...submit.input,
    barcode: "",
  } as Partial<Product>).toObject();

  return {
    product,
    rawResponse: JSON.stringify(submit.input),
  };
}

/**
 * Optional verification step for the Algolia search-by-name path. When the
 * fuzzy string match is ambiguous, ask Haiku to pick the matching candidate
 * (or "none") from the expected product description. Costs ~$0.0001 and
 * ~600ms per call but eliminates string-match false negatives like
 * "Royal Canin Kitten" vs "Royal Canin Junior" (semantic equivalence).
 *
 * Returns the matched candidate, or null if Haiku says "none of these".
 */
export async function verifyMatchWithLLM(
  expected: ProductIdentification,
  candidates: Product[]
): Promise<Product | null> {
  if (candidates.length === 0) return null;

  const candidateLines = candidates
    .map((c, i) => `${i}. brand="${c.brand}" name="${c.name}" foodType="${c.foodType}"`)
    .join("\n");

  const prompt =
    "A user scanned a cat food product identified as:\n" +
    `  brand="${expected.brand}" name="${expected.name}" foodType="${expected.foodType}"\n\n` +
    "Here are the closest cached candidates:\n" +
    `${candidateLines}\n\n` +
    "Pick the index of the candidate that is the SAME product (same brand, " +
    "same line/variant/flavor, same food type). If none of them is the same " +
    "product, pass -1. Differences in packaging size or pack count are fine; " +
    "differences in life stage (kitten vs adult), flavor, or formulation are not.";

  const tools: Anthropic.Tool[] = [
    {
      name: "submit_match",
      description:
        "Report which candidate (if any) is the same product as the scan",
      input_schema: {
        type: "object",
        required: ["matchIndex"],
        properties: {
          matchIndex: {
            type: "integer",
            minimum: -1,
            maximum: candidates.length - 1,
            description: "0-based index of the matching candidate, or -1 for none",
          },
        },
      },
    },
  ];

  try {
    const response = await withRetry("verifyMatchWithLLM", () =>
      getClient().messages.create({
        model: config.anthropic.model,
        max_tokens: 128,
        temperature: 0,
        messages: [{role: "user", content: [{type: "text", text: prompt}]}],
        tools,
        tool_choice: {type: "any"},
      })
    );

    const submit = findToolUse(response.content, "submit_match");
    const idx = submit?.input?.matchIndex;
    if (typeof idx !== "number" || idx < 0 || idx >= candidates.length) {
      logger.info("LLM verifier rejected all candidates", {
        expectedBrand: expected.brand,
        expectedName: expected.name,
        candidateCount: candidates.length,
        structuredData: true,
      });
      return null;
    }

    const winner = candidates[idx];
    logger.info("LLM verifier selected candidate", {
      expectedBrand: expected.brand,
      expectedName: expected.name,
      pickedBrand: winner.brand,
      pickedName: winner.name,
      pickedIndex: idx,
      structuredData: true,
    });
    return winner;
  } catch (error) {
    logger.warn("LLM verifier failed - skipping verification", {
      error: error instanceof Error ? error.message : String(error),
      structuredData: true,
    });
    return null;
  }
}
