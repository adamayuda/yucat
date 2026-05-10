/**
 * Application constants
 */

export const IMAGE_VALIDATION = {
  MIN_SIZE_BYTES: 100,
  HEADERS: {
    "User-Agent":
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
      "AppleWebKit/537.36",
    "Accept":
      "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
  },
} as const;

export const RETRY_CONFIG = {
  MAX_RETRIES: 2 as number,
  BASE_WAIT_TIME_MS: 1000 as number,
};

export const NUTRITIONAL_CONSTRAINTS = {
  DECIMAL_PLACES: 1,
  SCORE_MIN: 0,
  SCORE_MAX: 100,
  MAX_PROS: 3,
  MAX_CONS: 3,
} as const;

export const IMAGE_OPTIMIZATION = {
  MAX_WIDTH: 800,
  MAX_HEIGHT: 800,
  JPEG_QUALITY: 85,
  WEBP_QUALITY: 85,
  PNG_COMPRESSION: 9,
  OUTPUT_FORMAT: "jpeg",
  FIT: "inside" as const,
};
