/// Local, offline skincare ingredient knowledge base for the Ingredient
/// Analyzer. No network / paid API — a plain Dart const dataset.
library;

/// How a paired ingredient interacts with the analyzed one.
class IngredientCompat {
  final String ingredient;
  final bool compatible;
  const IngredientCompat(this.ingredient, this.compatible);
}

/// A safety indicator for an ingredient. The screen maps [rating] to a color.
enum IngredientSafety { safe, caution, sensitive }

class IngredientFact {
  final String name;
  final List<String> aliases;
  final IngredientSafety safety;
  final String rating;
  final List<String> benefits;
  final List<String> warnings;
  final String usage;
  final List<String> suitableSkinTypes;
  final List<IngredientCompat> compatibility;

  const IngredientFact({
    required this.name,
    this.aliases = const [],
    required this.safety,
    required this.rating,
    required this.benefits,
    required this.warnings,
    required this.usage,
    required this.suitableSkinTypes,
    required this.compatibility,
  });
}

/// The knowledge base — ~20 common skincare ingredients.
const List<IngredientFact> kIngredientFacts = [
  IngredientFact(
    name: 'Vitamin C',
    aliases: ['vitamin c', 'ascorbic acid', 'l-ascorbic acid', 'ascorbyl', 'vit c', 'sodium ascorbyl phosphate'],
    safety: IngredientSafety.caution,
    rating: 'Generally Safe',
    benefits: ['Brightens skin tone and evens complexion', 'Powerful antioxidant that fights free radicals', 'Fades hyperpigmentation and dark spots', 'Supports collagen synthesis for firmer skin'],
    warnings: ['Can irritate sensitive skin at high concentrations', 'Oxidizes with light and air — store in a cool, dark place', 'Introduce slowly to build tolerance'],
    usage: 'Apply a few drops in the morning on clean skin before moisturizer, then always follow with SPF.',
    suitableSkinTypes: ['Normal', 'Combination', 'Dull', 'Mature'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Vitamin E', true), IngredientCompat('Ferulic Acid', true), IngredientCompat('SPF', true), IngredientCompat('Retinol', false), IngredientCompat('AHA/BHA', false)],
  ),
  IngredientFact(
    name: 'Retinol',
    aliases: ['retinol', 'retinoid', 'retinaldehyde', 'retinal', 'retinyl palmitate', 'vitamin a'],
    safety: IngredientSafety.sensitive,
    rating: 'Use With Care',
    benefits: ['Accelerates cell turnover for smoother texture', 'Reduces fine lines and wrinkles', 'Helps clear and prevent breakouts', 'Fades post-acne marks and uneven tone over time'],
    warnings: ['Causes dryness, peeling and irritation when overused', 'Increases sun sensitivity — daily SPF is essential', 'Not recommended during pregnancy or breastfeeding', 'Start 1–2 nights a week and build up slowly'],
    usage: 'Apply a pea-sized amount at night on dry skin, then moisturize. Begin twice weekly and increase gradually.',
    suitableSkinTypes: ['Normal', 'Oily', 'Combination', 'Mature'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Ceramides', true), IngredientCompat('Niacinamide', true), IngredientCompat('Vitamin C', false), IngredientCompat('AHA/BHA', false), IngredientCompat('Benzoyl Peroxide', false)],
  ),
  IngredientFact(
    name: 'Niacinamide',
    aliases: ['niacinamide', 'vitamin b3', 'nicotinamide'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Regulates oil production and minimizes pores', 'Strengthens the skin barrier', 'Reduces redness and blotchiness', 'Brightens and evens skin tone'],
    warnings: ['Very high concentrations may cause mild flushing', 'Patch test if combining with strong acids'],
    usage: 'Apply morning and/or night after cleansing, before moisturizer. Works well at 2–10% concentration.',
    suitableSkinTypes: ['All skin types', 'Oily', 'Sensitive', 'Acne-prone'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', true), IngredientCompat('Zinc', true), IngredientCompat('Peptides', true), IngredientCompat('Vitamin C', false)],
  ),
  IngredientFact(
    name: 'Hyaluronic Acid',
    aliases: ['hyaluronic acid', 'hyaluronate', 'sodium hyaluronate', 'ha'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Holds up to 1000x its weight in water', 'Deeply hydrates and plumps skin', 'Smooths the look of fine lines', 'Compatible with nearly every routine'],
    warnings: ['Apply to damp skin — on dry air it can draw moisture out', 'Always seal with a moisturizer to lock in hydration'],
    usage: 'Apply to slightly damp skin morning and night, then follow immediately with a moisturizer.',
    suitableSkinTypes: ['All skin types', 'Dry', 'Dehydrated'],
    compatibility: [IngredientCompat('Vitamin C', true), IngredientCompat('Retinol', true), IngredientCompat('Niacinamide', true), IngredientCompat('AHA/BHA', true), IngredientCompat('Peptides', true)],
  ),
  IngredientFact(
    name: 'Salicylic Acid',
    aliases: ['salicylic acid', 'bha', 'beta hydroxy acid'],
    safety: IngredientSafety.caution,
    rating: 'Use With Care',
    benefits: ['Exfoliates inside pores to clear congestion', 'Reduces blackheads and whiteheads', 'Controls excess oil', 'Calms acne-related inflammation'],
    warnings: ['Can be drying — limit to once daily or less', 'Increases sun sensitivity — use SPF', 'Avoid layering with other strong exfoliants'],
    usage: 'Apply after cleansing, usually at night. Start 2–3 times a week and increase as tolerated.',
    suitableSkinTypes: ['Oily', 'Combination', 'Acne-prone'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', false), IngredientCompat('Vitamin C', false), IngredientCompat('AHA', false)],
  ),
  IngredientFact(
    name: 'Glycolic Acid',
    aliases: ['glycolic acid', 'aha', 'alpha hydroxy acid'],
    safety: IngredientSafety.caution,
    rating: 'Use With Care',
    benefits: ['Exfoliates surface dead skin cells', 'Brightens dull complexion', 'Smooths texture and fine lines', 'Helps fade dark spots'],
    warnings: ['Strong exfoliant — can irritate and cause peeling', 'Significantly increases sun sensitivity — SPF is a must', 'Do not combine with retinol or other acids in one routine'],
    usage: 'Apply at night after cleansing, 1–3 times per week. Always follow with SPF the next morning.',
    suitableSkinTypes: ['Normal', 'Combination', 'Dull', 'Mature'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Ceramides', true), IngredientCompat('Retinol', false), IngredientCompat('Vitamin C', false), IngredientCompat('BHA', false)],
  ),
  IngredientFact(
    name: 'Lactic Acid',
    aliases: ['lactic acid'],
    safety: IngredientSafety.caution,
    rating: 'Use With Care',
    benefits: ['Gentle AHA exfoliation for sensitive skin', 'Improves texture and softness', 'Boosts surface hydration', 'Brightens uneven tone'],
    warnings: ['Still increases sun sensitivity — use SPF', 'Can irritate if overused', 'Avoid stacking with other acids or retinol'],
    usage: 'Apply at night 1–3 times weekly after cleansing, then moisturize. Follow with SPF the next day.',
    suitableSkinTypes: ['Dry', 'Sensitive', 'Normal', 'Dull'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Ceramides', true), IngredientCompat('Niacinamide', true), IngredientCompat('Retinol', false), IngredientCompat('Vitamin C', false)],
  ),
  IngredientFact(
    name: 'Ceramides',
    aliases: ['ceramide', 'ceramides'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Restores and strengthens the skin barrier', 'Locks in moisture and reduces water loss', 'Soothes dryness and irritation', 'Improves resilience of sensitive skin'],
    warnings: ['Very safe — no significant cautions for most people', 'Patch test any new formula if highly reactive'],
    usage: 'Apply morning and night as part of your moisturizer or after serums to seal the barrier.',
    suitableSkinTypes: ['All skin types', 'Dry', 'Sensitive'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Niacinamide', true), IngredientCompat('Retinol', true), IngredientCompat('Peptides', true), IngredientCompat('AHA/BHA', true)],
  ),
  IngredientFact(
    name: 'Vitamin E',
    aliases: ['vitamin e', 'tocopherol', 'tocopheryl acetate'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Antioxidant that protects against free radicals', 'Moisturizes and softens skin', 'Supports the skin barrier', 'Boosts stability of Vitamin C'],
    warnings: ['Pure oil can feel heavy or clog very oily skin', 'Rarely causes contact irritation — patch test'],
    usage: 'Use morning or night in a serum or moisturizer. Pairs especially well with Vitamin C in the AM.',
    suitableSkinTypes: ['Normal', 'Dry', 'Mature'],
    compatibility: [IngredientCompat('Vitamin C', true), IngredientCompat('Ferulic Acid', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', true)],
  ),
  IngredientFact(
    name: 'Peptides',
    aliases: ['peptide', 'peptides', 'matrixyl', 'copper peptides'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Signal skin to produce more collagen', 'Improve firmness and elasticity', 'Help smooth fine lines', 'Support barrier repair'],
    warnings: ['Effects are gradual — consistency matters', 'Avoid layering copper peptides with strong acids or Vitamin C'],
    usage: 'Apply morning and/or night after cleansing, before moisturizer.',
    suitableSkinTypes: ['All skin types', 'Mature', 'Dry'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Niacinamide', true), IngredientCompat('Ceramides', true), IngredientCompat('Vitamin C', false), IngredientCompat('AHA/BHA', false)],
  ),
  IngredientFact(
    name: 'Zinc Oxide',
    aliases: ['zinc oxide', 'zinc'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Broad-spectrum mineral UV protection', 'Soothes irritated and sensitive skin', 'Helps calm redness and inflammation', 'Gentle enough for reactive skin'],
    warnings: ['Can leave a white cast on deeper skin tones', 'Reapply every 2 hours in sun for protection'],
    usage: 'Apply as the last step of your morning routine as sunscreen, and reapply throughout sun exposure.',
    suitableSkinTypes: ['All skin types', 'Sensitive', 'Acne-prone'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Ceramides', true), IngredientCompat('Vitamin C', true)],
  ),
  IngredientFact(
    name: 'Benzoyl Peroxide',
    aliases: ['benzoyl peroxide', 'bpo'],
    safety: IngredientSafety.sensitive,
    rating: 'Use With Care',
    benefits: ['Kills acne-causing bacteria', 'Clears and prevents breakouts', 'Reduces inflammatory pimples', 'Helps unclog pores'],
    warnings: ['Very drying and can cause peeling', 'Bleaches fabrics, towels and pillowcases', 'Do not use at the same time as retinol or Vitamin C', 'Increases sun sensitivity'],
    usage: 'Apply a thin layer to affected areas once daily; start low (2.5–5%) and buffer with moisturizer.',
    suitableSkinTypes: ['Oily', 'Acne-prone'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', false), IngredientCompat('Vitamin C', false), IngredientCompat('AHA/BHA', false)],
  ),
  IngredientFact(
    name: 'Azelaic Acid',
    aliases: ['azelaic acid'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Reduces redness and rosacea symptoms', 'Fades post-acne dark marks', 'Gently unclogs pores', 'Evens skin tone'],
    warnings: ['Mild tingling or dryness when starting', 'Introduce gradually to build tolerance'],
    usage: 'Apply a thin layer once or twice daily after cleansing, before moisturizer.',
    suitableSkinTypes: ['Sensitive', 'Acne-prone', 'Rosacea-prone', 'All'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', true), IngredientCompat('Vitamin C', true)],
  ),
  IngredientFact(
    name: 'Squalane',
    aliases: ['squalane', 'squalene'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Lightweight, non-greasy moisture', 'Mimics the skin\'s natural oils', 'Softens and smooths skin', 'Supports the barrier without clogging pores'],
    warnings: ['Very well tolerated — minimal cautions', 'Choose stable squalane over raw squalene'],
    usage: 'Apply a few drops as one of the last steps, morning or night, to seal in hydration.',
    suitableSkinTypes: ['All skin types', 'Dry', 'Sensitive', 'Oily'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', true), IngredientCompat('Niacinamide', true), IngredientCompat('Vitamin C', true)],
  ),
  IngredientFact(
    name: 'Collagen',
    aliases: ['collagen', 'hydrolyzed collagen'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Adds surface hydration and plumpness', 'Helps skin feel smoother', 'Forms a light moisture-retaining film', 'Pairs well with humectants'],
    warnings: ['Topical collagen molecules are too large to replace lost collagen', 'Best for hydration rather than structural repair'],
    usage: 'Apply in a serum or moisturizer morning and night for a plumping, hydrating effect.',
    suitableSkinTypes: ['All skin types', 'Dry', 'Mature'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Peptides', true), IngredientCompat('Niacinamide', true), IngredientCompat('Vitamin C', true)],
  ),
  IngredientFact(
    name: 'Panthenol',
    aliases: ['panthenol', 'provitamin b5', 'vitamin b5', 'pro-vitamin b5'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Deeply soothes and calms irritation', 'Boosts hydration and softness', 'Supports skin barrier repair', 'Reduces redness'],
    warnings: ['Extremely gentle — no notable cautions', 'Patch test if you react to most products'],
    usage: 'Use morning and night in a serum or moisturizer; great for calming compromised skin.',
    suitableSkinTypes: ['All skin types', 'Sensitive', 'Dry'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Niacinamide', true), IngredientCompat('Ceramides', true), IngredientCompat('Retinol', true)],
  ),
  IngredientFact(
    name: 'Alpha Arbutin',
    aliases: ['alpha arbutin', 'arbutin'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Fades dark spots and hyperpigmentation', 'Brightens uneven tone gently', 'Safer alternative to hydroquinone', 'Suitable for sensitive skin'],
    warnings: ['Results are gradual — use consistently', 'Pair with SPF to prevent new pigmentation'],
    usage: 'Apply morning and/or night after cleansing, before moisturizer; always use SPF during the day.',
    suitableSkinTypes: ['All skin types', 'Sensitive', 'Dull'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Vitamin C', true), IngredientCompat('SPF', true)],
  ),
  IngredientFact(
    name: 'Tea Tree',
    aliases: ['tea tree', 'tea tree oil', 'melaleuca'],
    safety: IngredientSafety.caution,
    rating: 'Use With Care',
    benefits: ['Natural antibacterial for spot treatment', 'Helps reduce blemishes', 'Controls excess oil', 'Calms inflamed breakouts'],
    warnings: ['Undiluted oil can burn or sensitize skin', 'Always use in a diluted formulation', 'Can cause allergic reactions — patch test first'],
    usage: 'Dab a diluted formula onto blemishes as a spot treatment, not all over the face.',
    suitableSkinTypes: ['Oily', 'Acne-prone'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Retinol', false), IngredientCompat('Benzoyl Peroxide', false)],
  ),
  IngredientFact(
    name: 'Aloe Vera',
    aliases: ['aloe vera', 'aloe', 'aloe barbadensis'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Soothes and cools irritated skin', 'Lightweight hydration', 'Helps calm redness and sunburn', 'Non-greasy comfort for oily skin'],
    warnings: ['Some people are allergic — patch test', 'Alcohol-heavy aloe gels can be drying'],
    usage: 'Apply as a hydrating, soothing layer morning or night, or after sun exposure.',
    suitableSkinTypes: ['All skin types', 'Oily', 'Sensitive'],
    compatibility: [IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Niacinamide', true), IngredientCompat('Vitamin C', true), IngredientCompat('Ceramides', true)],
  ),
  IngredientFact(
    name: 'Centella Asiatica',
    aliases: ['centella asiatica', 'centella', 'cica', 'madecassoside', 'gotu kola', 'tiger grass'],
    safety: IngredientSafety.safe,
    rating: 'Well Tolerated',
    benefits: ['Calms redness and irritation', 'Supports barrier repair and healing', 'Rich in soothing antioxidants', 'Great for compromised or reactive skin'],
    warnings: ['Very gentle — minimal cautions', 'Patch test if highly allergy-prone'],
    usage: 'Apply morning and night after cleansing to soothe and strengthen the barrier.',
    suitableSkinTypes: ['All skin types', 'Sensitive', 'Redness-prone'],
    compatibility: [IngredientCompat('Niacinamide', true), IngredientCompat('Hyaluronic Acid', true), IngredientCompat('Ceramides', true), IngredientCompat('Retinol', true)],
  ),
];

/// Case-insensitive lookup with light fuzzy/contains matching.
IngredientFact? lookupIngredient(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return null;

  for (final fact in kIngredientFacts) {
    if (fact.name.toLowerCase() == q || fact.aliases.contains(q)) return fact;
  }

  for (final fact in kIngredientFacts) {
    if (fact.name.toLowerCase().contains(q) || q.contains(fact.name.toLowerCase())) {
      return fact;
    }
    for (final alias in fact.aliases) {
      if (alias.contains(q) || q.contains(alias)) return fact;
    }
  }

  final queryWords = q.split(RegExp(r'[^a-z0-9]+')).where((w) => w.length >= 3).toSet();
  if (queryWords.isNotEmpty) {
    for (final fact in kIngredientFacts) {
      final factWords = <String>{
        ...fact.name.toLowerCase().split(RegExp(r'[^a-z0-9]+')),
        for (final a in fact.aliases) ...a.split(RegExp(r'[^a-z0-9]+')),
      }.where((w) => w.length >= 3).toSet();
      if (queryWords.intersection(factWords).isNotEmpty) return fact;
    }
  }

  return null;
}
