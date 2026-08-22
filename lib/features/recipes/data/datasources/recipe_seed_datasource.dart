import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';

/// Hard-coded recipe catalogue.
///
/// **This is the backend swap point.** When recipes are served remotely, replace
/// this class with a Firestore/Algolia datasource returning the same
/// `List<RecipeEntity>` — nothing above it has to change.
///
/// Copy is canonical English on purpose (see `RecipeEntity.name`); the backend
/// will carry translations, so these strings deliberately do not go through the
/// ARB files.
class RecipeSeedDataSource {
  const RecipeSeedDataSource();

  Future<List<RecipeEntity>> getRecipes() async => _kSeedRecipes;
}

const List<RecipeEntity> _kSeedRecipes = [
  RecipeEntity(
    id: 'tuna-biscuits',
    name: 'Tuna biscuits',
    description:
        'Crunchy little biscuits baked from canned tuna and oat flour. '
        'Keep for a week in an airtight tin.',
    category: RecipeCategory.biscuits,
    prepMinutes: 25,
    difficulty: RecipeDifficulty.easy,
    compatibility: RecipeCompatibility.compatible,
    ingredients: [
      RecipeIngredient(name: 'Canned tuna in spring water', quantity: '120 g'),
      RecipeIngredient(name: 'Oat flour', quantity: '60 g'),
      RecipeIngredient(name: 'Egg', quantity: '1'),
      RecipeIngredient(name: 'Water', quantity: '1 tbsp'),
    ],
    steps: [
      'Heat the oven to 180 C and line a tray with baking paper.',
      'Drain the tuna well and mash it smooth with a fork.',
      'Mix in the oat flour and egg until it forms a stiff dough, adding the water only if it stays crumbly.',
      'Roll into small balls and flatten each one with a fork.',
      'Bake for 15 minutes, until firm and lightly golden. Cool completely before serving.',
    ],
    tip: 'Use tuna packed in spring water, never brine or oil - the salt in brine is hard on feline kidneys.',
  ),
  RecipeEntity(
    id: 'chicken-biscuits',
    name: 'Chicken biscuits',
    description:
        'Shredded chicken breast bound with egg and a little rice flour. '
        'A lean, high-protein treat with no added salt.',
    category: RecipeCategory.biscuits,
    prepMinutes: 25,
    difficulty: RecipeDifficulty.easy,
    compatibility: RecipeCompatibility.compatible,
    ingredients: [
      RecipeIngredient(name: 'Cooked chicken breast', quantity: '150 g'),
      RecipeIngredient(name: 'Rice flour', quantity: '50 g'),
      RecipeIngredient(name: 'Egg', quantity: '1'),
    ],
    steps: [
      'Heat the oven to 180 C and line a tray with baking paper.',
      'Shred the cooked chicken as finely as you can, or pulse it briefly in a blender.',
      'Work in the egg and rice flour until the mixture holds together.',
      'Shape into small nuggets and space them out on the tray.',
      'Bake for 18 minutes, then leave to cool on a rack.',
    ],
    tip: 'Poach the chicken plain. Anything roasted with onion or garlic is toxic to cats, even in small amounts.',
  ),
  RecipeEntity(
    id: 'salmon-catnip-biscuits',
    name: 'Salmon and catnip biscuits',
    description:
        'Baked salmon crumbs with a pinch of dried catnip folded through. '
        'Rich in omega-3 for a glossy coat.',
    category: RecipeCategory.biscuits,
    prepMinutes: 35,
    difficulty: RecipeDifficulty.medium,
    compatibility: RecipeCompatibility.caution,
    ingredients: [
      RecipeIngredient(name: 'Cooked salmon fillet, skinless and boneless', quantity: '120 g'),
      RecipeIngredient(name: 'Oat flour', quantity: '70 g'),
      RecipeIngredient(name: 'Egg', quantity: '1'),
      RecipeIngredient(name: 'Dried catnip', quantity: 'a pinch'),
    ],
    steps: [
      'Heat the oven to 175 C and line a tray with baking paper.',
      'Flake the salmon carefully, checking by hand for any bones.',
      'Combine with the oat flour, egg and catnip into a soft dough.',
      'Roll out to about 5 mm thick and cut into small squares.',
      'Bake for 20 minutes, then cool fully before serving.',
    ],
    tip: 'Check the salmon twice for pin bones. Not every cat reacts to catnip, so leave it out if yours does not.',
  ),
  RecipeEntity(
    id: 'tuna-mini-cake',
    name: 'Tuna mini-cake',
    description:
        'A single-serving savoury cake steamed in a ramekin. '
        'Soft enough for older cats who struggle with crunch.',
    category: RecipeCategory.cakes,
    prepMinutes: 20,
    difficulty: RecipeDifficulty.easy,
    compatibility: RecipeCompatibility.compatible,
    ingredients: [
      RecipeIngredient(name: 'Canned tuna in spring water', quantity: '80 g'),
      RecipeIngredient(name: 'Egg', quantity: '1'),
      RecipeIngredient(name: 'Cooked mashed pumpkin', quantity: '1 tbsp'),
    ],
    steps: [
      'Drain the tuna and blend it with the egg and pumpkin until smooth.',
      'Spoon into a small greased ramekin.',
      'Steam over simmering water for 15 minutes, until set in the middle.',
      'Turn out and let it cool to room temperature before serving.',
    ],
    tip: 'The soft texture suits senior cats and anyone recovering from dental work.',
  ),
  RecipeEntity(
    id: 'birthday-pate-cake',
    name: 'Birthday pate cake',
    description:
        'Layered wet food pressed into a mould and topped with a swirl of '
        'plain pate. Assemble it the morning of, serve it cold.',
    category: RecipeCategory.cakes,
    prepMinutes: 40,
    difficulty: RecipeDifficulty.hard,
    compatibility: RecipeCompatibility.caution,
    ingredients: [
      RecipeIngredient(name: "Your cat's usual wet food", quantity: '150 g'),
      RecipeIngredient(name: 'Cooked mashed sweet potato', quantity: '2 tbsp'),
      RecipeIngredient(name: 'Cooked chicken, shredded', quantity: '30 g'),
    ],
    steps: [
      'Line a small ramekin with cling film, leaving an overhang to lift by.',
      'Press in half the wet food as an even base layer.',
      'Add the sweet potato as a middle layer, then the rest of the wet food.',
      'Chill for 2 hours so the layers firm up.',
      'Lift out, peel away the film and top with the shredded chicken.',
    ],
    tip: 'Assemble it the morning of and keep it refrigerated. Serve cool, not frozen.',
  ),
  RecipeEntity(
    id: 'liver-loaf',
    name: 'Chicken liver loaf',
    description:
        'Gently poached liver blended smooth and set in a small loaf tin. '
        'Very rich in vitamin A, so serve only a thin slice.',
    category: RecipeCategory.cakes,
    prepMinutes: 45,
    difficulty: RecipeDifficulty.medium,
    compatibility: RecipeCompatibility.incompatible,
    ingredients: [
      RecipeIngredient(name: 'Chicken liver', quantity: '200 g'),
      RecipeIngredient(name: 'Egg', quantity: '1'),
      RecipeIngredient(name: 'Oat flour', quantity: '30 g'),
    ],
    steps: [
      'Poach the liver in plain water for 10 minutes, then drain.',
      'Blend to a smooth paste with the egg and oat flour.',
      'Pour into a small loaf tin lined with baking paper.',
      'Bake at 170 C for 25 minutes, until set and firm to the touch.',
      'Cool completely, then slice thinly and refrigerate.',
    ],
    tip: 'Liver is extremely high in vitamin A, which builds up over time. One thin slice a week at most, and skip it entirely for cats on a prescribed diet.',
  ),
  RecipeEntity(
    id: 'frozen-tuna-bites',
    name: 'Frozen tuna bites',
    description:
        'Tuna blended with its own spring water and frozen in an ice tray. '
        'A cooling treat that also nudges up water intake.',
    category: RecipeCategory.frozenTreats,
    prepMinutes: 5,
    requiresFreezing: true,
    difficulty: RecipeDifficulty.easy,
    compatibility: RecipeCompatibility.compatible,
    ingredients: [
      RecipeIngredient(name: 'Canned tuna in spring water', quantity: '80 g'),
      RecipeIngredient(name: 'The water from the tin', quantity: '80 ml'),
    ],
    steps: [
      'Blend the tuna with its own spring water until smooth.',
      'Pour into an ice cube tray.',
      'Freeze for at least 4 hours.',
      'Serve one cube at a time, slightly softened.',
    ],
    tip: 'Let each cube sit for a minute before serving - straight from the freezer it is too cold on the tongue.',
  ),
  RecipeEntity(
    id: 'frozen-pate-bites',
    name: 'Frozen pate bites',
    description:
        'Your cat\'s usual pate pushed through a piping bag and frozen into '
        'nuggets. Zero new ingredients, so almost any cat can have them.',
    category: RecipeCategory.frozenTreats,
    prepMinutes: 5,
    requiresFreezing: true,
    difficulty: RecipeDifficulty.easy,
    compatibility: RecipeCompatibility.compatible,
    ingredients: [
      RecipeIngredient(name: 'Complete wet cat food', quantity: '80 g'),
      RecipeIngredient(name: 'Water', quantity: '80 ml'),
    ],
    steps: [
      'Thin the wet food with the water until you have a smooth mixture.',
      'Spoon into an ice cube tray.',
      'Freeze for at least 4 hours.',
      'Serve one cube at a time, slightly softened.',
    ],
    tip: "Using your cat's usual food avoids introducing anything new, so even sensitive stomachs handle it well.",
  ),
  RecipeEntity(
    id: 'frozen-broth-cubes',
    name: 'Frozen broth cubes',
    description:
        'Unsalted chicken broth simmered from bones, strained and frozen. '
        'Drop one into the water bowl on a hot day.',
    category: RecipeCategory.frozenTreats,
    prepMinutes: 15,
    requiresFreezing: true,
    difficulty: RecipeDifficulty.medium,
    compatibility: RecipeCompatibility.caution,
    ingredients: [
      RecipeIngredient(name: 'Chicken carcass or wings, unseasoned', quantity: '300 g'),
      RecipeIngredient(name: 'Water', quantity: '1 L'),
    ],
    steps: [
      'Simmer the chicken in the water for 2 hours with nothing added.',
      'Strain thoroughly and discard every bone - cooked bones splinter.',
      'Let the broth cool, then skim the fat off the top.',
      'Pour into an ice cube tray and freeze for at least 4 hours.',
    ],
    tip: 'No salt, no onion, no garlic, no stock cube. Plain water and chicken only.',
  ),
];
