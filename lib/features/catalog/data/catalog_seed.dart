import 'package:flutter/material.dart';

import '../domain/ingredient.dart';
import '../domain/product.dart';

/// Offline seed catalog. This is the single replacement for the old, scattered
/// mock product lists. Repositories serve this when Firestore is unavailable,
/// and it doubles as the data you'd upload to seed the `products` /
/// `ingredients` collections (see FIREBASE_SETUP / a seeding script).

final catalogProducts = <Product>[
  Product(
    id: '1', name: 'Hydra-Boost Cleanser', brand: 'CeraVe', category: 'Cleanser',
    score: 92, color: const Color(0xFF7C5CFF), barcode: '8901030865278',
    expiryDate: DateTime(2026, 12, 1), purchaseDate: DateTime(2026, 1, 10),
    isFavourite: true,
    benefits: const [
      'Gently removes impurities without stripping',
      'Restores the protective skin barrier',
      'Retains natural moisture balance',
    ],
    safeIngredients: const ['Ceramide NP', 'Niacinamide', 'Hyaluronic Acid', 'Glycerin'],
    howToUse: 'Apply to damp face, massage 30 seconds, rinse with lukewarm water. AM & PM.',
    skinMatch: 94, hairMatch: 65,
  ),
  Product(
    id: '2', name: 'Moisture Surge 72H', brand: 'Clinique', category: 'Moisturizer',
    score: 88, color: const Color(0xFF06B6D4), barcode: '0020714248819',
    expiryDate: DateTime(2026, 7, 5), purchaseDate: DateTime(2025, 7, 5),
    isFavourite: true,
    benefits: const ['72-hour continuous hydration', 'Lightweight gel formula'],
    safeIngredients: const ['Aloe Vera', 'Glycerin', 'Hyaluronic Acid', 'Caffeine'],
    cautionIngredients: const ['Fragrance'],
    howToUse: 'Apply AM and/or PM to cleansed skin.',
    skinMatch: 89, hairMatch: 55,
  ),
  Product(
    id: '3', name: 'Retinol 0.5% Serum', brand: "Paula's Choice", category: 'Serum',
    score: 76, color: const Color(0xFFEC4899),
    expiryDate: DateTime(2026, 6, 20), purchaseDate: DateTime(2025, 12, 15),
    benefits: const ['Reduces fine lines', 'Improves texture', 'Boosts collagen'],
    safeIngredients: const ['Retinol', 'Glycerin', 'Squalane', 'Vitamin E'],
    cautionIngredients: const ['Retinol'],
    howToUse: 'Apply at night after cleansing. Start 2–3 nights/week. Use SPF in the AM.',
    skinMatch: 78, hairMatch: 60,
  ),
  Product(
    id: '4', name: 'Ultra Defense SPF 50+', brand: 'La Roche-Posay', category: 'Sunscreen',
    score: 95, color: const Color(0xFF22C55E), barcode: '3337875597197',
    expiryDate: DateTime(2027, 3, 1), purchaseDate: DateTime(2026, 3, 1),
    benefits: const ['Broad-spectrum UVA/UVB', 'Water-resistant 80 min', 'Non-comedogenic'],
    safeIngredients: const ['Avobenzone', 'Niacinamide', 'Glycerin'],
    howToUse: 'Apply generously 15 min before sun. Reapply every 2 hours.',
    skinMatch: 96, hairMatch: 50,
  ),
  Product(
    id: '5', name: 'Barrier Repair Cream', brand: 'Avène', category: 'Treatment',
    score: 90, color: const Color(0xFFF59E0B),
    expiryDate: DateTime(2026, 5, 30), purchaseDate: DateTime(2025, 11, 1),
    benefits: const ['Repairs skin barrier', 'Soothes irritation', 'Reduces redness'],
    safeIngredients: const ['Glycerin', 'Ceramide NP', 'Squalane'],
    howToUse: 'Apply AM and PM after cleansing.',
    skinMatch: 92, hairMatch: 45,
  ),
  Product(
    id: '6', name: 'Glycolic Toner 7%', brand: 'The Ordinary', category: 'Toner',
    score: 81, color: const Color(0xFF8B5CF6),
    expiryDate: DateTime(2027, 8, 15), purchaseDate: DateTime(2026, 2, 20),
    isFavourite: true,
    benefits: const ['Gently exfoliates', 'Improves radiance', 'Minimizes pores'],
    safeIngredients: const ['Aloe Vera', 'Glycerin'],
    cautionIngredients: const ['Glycolic Acid'],
    howToUse: 'Apply PM with a cotton pad 3–4×/week. Use SPF the next morning.',
    skinMatch: 83, hairMatch: 40,
  ),
  Product(
    id: '7', name: 'Vitamin C Brightening', brand: 'SkinCeuticals', category: 'Serum',
    score: 85, color: const Color(0xFFFF8C42),
    expiryDate: DateTime(2026, 6, 15), purchaseDate: DateTime(2025, 12, 15),
    benefits: const ['Brightens uneven tone', 'Antioxidant protection', 'Boosts collagen'],
    safeIngredients: const ['Vitamin C', 'Vitamin E', 'Glycerin'],
    howToUse: 'Apply 4–5 drops every morning before moisturizer and SPF.',
    skinMatch: 86, hairMatch: 58,
  ),
  Product(
    id: '8', name: 'Niacinamide 10%', brand: 'The Ordinary', category: 'Treatment',
    score: 93, color: const Color(0xFF14B8A6),
    expiryDate: DateTime(2027, 11, 1), purchaseDate: DateTime(2026, 5, 1),
    benefits: const ['Reduces blemishes', 'Minimizes pores', 'Regulates sebum'],
    safeIngredients: const ['Niacinamide', 'Zinc PCA', 'Glycerin'],
    howToUse: 'Apply a few drops AM and PM before heavier creams.',
    skinMatch: 95, hairMatch: 72,
  ),
];

final catalogIngredients = <Ingredient>[
  const Ingredient(
    id: 'niacinamide', name: 'Niacinamide', inciName: 'Niacinamide',
    category: 'Active', function: 'Brightening / sebum control', safetyScore: 95,
    description: 'A form of vitamin B3 that brightens, controls oil and supports the barrier.',
    benefits: ['Evens skin tone', 'Minimizes pores', 'Strengthens barrier'],
    suitableFor: ['Oily', 'Combination', 'Sensitive'],
  ),
  const Ingredient(
    id: 'hyaluronic-acid', name: 'Hyaluronic Acid', inciName: 'Sodium Hyaluronate',
    category: 'Humectant', function: 'Hydration', safetyScore: 97,
    description: 'Holds up to 1000× its weight in water for plump, hydrated skin.',
    benefits: ['Deep hydration', 'Plumps fine lines'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'glycerin', name: 'Glycerin', inciName: 'Glycerin',
    category: 'Humectant', function: 'Hydration', safetyScore: 98,
    description: 'A gentle humectant that draws moisture into the skin.',
    benefits: ['Hydrates', 'Soothes'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'ceramide-np', name: 'Ceramide NP', inciName: 'Ceramide NP',
    category: 'Barrier lipid', function: 'Barrier repair', safetyScore: 96,
    description: 'A skin-identical lipid that restores and reinforces the moisture barrier.',
    benefits: ['Repairs barrier', 'Locks in moisture'], suitableFor: ['Dry', 'Sensitive'],
  ),
  const Ingredient(
    id: 'retinol', name: 'Retinol', inciName: 'Retinol',
    category: 'Active', function: 'Cell renewal', safetyScore: 72, flagged: true,
    description: 'A vitamin A derivative that accelerates renewal; can irritate and increases sun sensitivity.',
    benefits: ['Reduces wrinkles', 'Improves texture'],
    concerns: ['Irritation', 'Sun sensitivity', 'Not for pregnancy'],
    suitableFor: ['Normal', 'Oily'],
  ),
  const Ingredient(
    id: 'glycolic-acid', name: 'Glycolic Acid', inciName: 'Glycolic Acid',
    category: 'Exfoliant (AHA)', function: 'Exfoliation', safetyScore: 74, flagged: true,
    description: 'An alpha-hydroxy acid that exfoliates the surface; increases sun sensitivity.',
    benefits: ['Smooths texture', 'Brightens'],
    concerns: ['Sun sensitivity', 'Stinging'], suitableFor: ['Normal', 'Oily'],
  ),
  const Ingredient(
    id: 'salicylic-acid', name: 'Salicylic Acid', inciName: 'Salicylic Acid',
    category: 'Exfoliant (BHA)', function: 'Pore clearing', safetyScore: 80,
    description: 'An oil-soluble BHA that unclogs pores; great for acne-prone skin.',
    benefits: ['Clears pores', 'Reduces breakouts'], suitableFor: ['Oily', 'Combination'],
  ),
  const Ingredient(
    id: 'vitamin-c', name: 'Vitamin C', inciName: 'Ascorbic Acid',
    category: 'Antioxidant', function: 'Brightening', safetyScore: 86,
    description: 'A potent antioxidant that brightens and protects against free radicals.',
    benefits: ['Brightens', 'Antioxidant defense'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'vitamin-e', name: 'Vitamin E', inciName: 'Tocopherol',
    category: 'Antioxidant', function: 'Protection', safetyScore: 92,
    description: 'A nourishing antioxidant that stabilises formulas and protects skin.',
    benefits: ['Moisturizes', 'Antioxidant'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'squalane', name: 'Squalane', inciName: 'Squalane',
    category: 'Emollient', function: 'Moisture seal', safetyScore: 95,
    description: 'A lightweight, non-comedogenic emollient that softens and seals moisture.',
    benefits: ['Softens', 'Non-greasy hydration'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'zinc-pca', name: 'Zinc PCA', inciName: 'Zinc PCA',
    category: 'Active', function: 'Oil control', safetyScore: 90,
    description: 'Helps regulate sebum and calm blemish-prone skin.',
    benefits: ['Controls oil', 'Calms skin'], suitableFor: ['Oily', 'Combination'],
  ),
  const Ingredient(
    id: 'avobenzone', name: 'Avobenzone', inciName: 'Avobenzone',
    category: 'UV filter', function: 'Sun protection', safetyScore: 82,
    description: 'A broad-spectrum chemical UVA filter.',
    benefits: ['UVA protection'], concerns: ['Can degrade without stabilisers'],
    suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'aloe-vera', name: 'Aloe Vera', inciName: 'Aloe Barbadensis',
    category: 'Soothing', function: 'Calming', safetyScore: 94,
    description: 'A soothing botanical that calms and lightly hydrates.',
    benefits: ['Soothes', 'Calms redness'], suitableFor: ['Sensitive', 'All'],
  ),
  const Ingredient(
    id: 'caffeine', name: 'Caffeine', inciName: 'Caffeine',
    category: 'Active', function: 'De-puffing', safetyScore: 88,
    description: 'An antioxidant that temporarily reduces puffiness and the look of dark circles.',
    benefits: ['De-puffs', 'Antioxidant'], suitableFor: ['All'],
  ),
  const Ingredient(
    id: 'fragrance', name: 'Fragrance', inciName: 'Parfum',
    category: 'Additive', function: 'Scent', safetyScore: 45, flagged: true,
    description: 'Added scent — a common irritant and allergen for sensitive skin.',
    concerns: ['Irritation', 'Allergen'], suitableFor: ['Normal'],
  ),
  const Ingredient(
    id: 'alcohol-denat', name: 'Alcohol Denat', inciName: 'Alcohol Denat.',
    category: 'Solvent', function: 'Quick-dry / penetration', safetyScore: 50, flagged: true,
    description: 'A drying alcohol that can compromise the barrier in high amounts.',
    concerns: ['Drying', 'Barrier disruption'], suitableFor: ['Oily'],
  ),
  const Ingredient(
    id: 'sls', name: 'Sodium Laureth Sulfate', inciName: 'Sodium Laureth Sulfate',
    category: 'Surfactant', function: 'Cleansing / foaming', safetyScore: 55, flagged: true,
    description: 'A strong foaming cleanser that can strip and irritate sensitive skin.',
    concerns: ['Stripping', 'Irritation'], suitableFor: ['Oily'],
  ),
];
