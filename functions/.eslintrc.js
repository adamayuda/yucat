module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*",
    "/generated/**/*",
    "/scripts/**/*",
  ],
  plugins: ["@typescript-eslint", "import"],
  rules: {
    quotes: ["error", "double"],
    "import/no-unresolved": 0,
    indent: ["error", 2],
    camelcase: "off",
    "quote-props": "off",
    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    "max-len": ["error", {code: 100, ignoreUrls: true, ignoreStrings: true}],
    "@typescript-eslint/naming-convention": [
      "error",
      {
        selector: "default",
        format: ["camelCase", "PascalCase", "snake_case", "UPPER_CASE"],
      },
      {
        selector: "property",
        format: null,
        filter: {
          regex: "[/-]",
          match: true,
        },
      },
    ],
  },
};
