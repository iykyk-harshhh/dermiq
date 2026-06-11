import 'package:flutter/material.dart';
import 'shop_models.dart';

const List<ShopProduct> shopProducts = [
  // ─── SKINCARE ────────────────────────────────────────────────────────────

  ShopProduct(
    id: 'sk001',
    name: 'Hydrating Facial Cleanser',
    brand: 'CeraVe',
    category: 'Skincare',
    subCategory: 'Cleanser',
    description:
        'A gentle, non-foaming cleanser formulated with three essential ceramides and hyaluronic acid to maintain the skin\'s natural barrier. '
        'Developed with dermatologists, it effectively removes dirt, oil, and makeup without stripping moisture. '
        'Fragrance-free and non-comedogenic, it is suitable for sensitive and dry skin types.',
    howToUse:
        'Apply to damp skin and massage gently in circular motions. '
        'Rinse thoroughly with lukewarm water and pat dry. '
        'Use morning and evening as the first step of your skincare routine.',
    price: 599,
    originalPrice: 799,
    rating: 4.8,
    reviewCount: 742,
    dermiqMatchScore: 94,
    accentColor: Color(0xFF06B6D4),
    benefits: [
      'Maintains skin moisture barrier',
      'Gentle enough for daily use',
      'Non-comedogenic formula',
    ],
    ingredients: [
      'Ceramide NP',
      'Ceramide AP',
      'Ceramide EOP',
      'Hyaluronic Acid',
      'Niacinamide',
      'Cholesterol',
    ],
    skinTypes: ['Dry', 'Normal', 'Sensitive', 'Combination'],
    concerns: ['Dryness', 'Sensitivity', 'Dull Skin'],
    isFeatured: true,
  ),

  ShopProduct(
    id: 'sk002',
    name: 'Moisturizing Cream',
    brand: 'Cetaphil',
    category: 'Skincare',
    subCategory: 'Moisturizer',
    description:
        'A rich, long-lasting moisturizer that provides 48-hour hydration for dry to very dry skin. '
        'Its non-greasy formula with glycerin and sweet almond oil helps restore and protect the skin\'s natural moisture barrier. '
        'Clinically proven to soothe and hydrate even the most sensitive skin.',
    howToUse:
        'Apply a generous amount to cleansed face and body as needed. '
        'Gently massage into skin until fully absorbed. '
        'Can be used day and night; re-apply whenever skin feels dry.',
    price: 449,
    originalPrice: 549,
    rating: 4.7,
    reviewCount: 615,
    dermiqMatchScore: 90,
    accentColor: Color(0xFF10B981),
    benefits: [
      '48-hour hydration',
      'Restores skin barrier',
      'Suitable for sensitive skin',
    ],
    ingredients: [
      'Glycerin',
      'Sweet Almond Oil',
      'Vitamin B5',
      'Niacinamide',
      'Allantoin',
    ],
    skinTypes: ['Dry', 'Very Dry', 'Sensitive'],
    concerns: ['Dryness', 'Flakiness', 'Sensitivity'],
    isFeatured: false,
  ),

  ShopProduct(
    id: 'sk003',
    name: 'Niacinamide 10% + Zinc 1% Serum',
    brand: 'The Ordinary',
    category: 'Skincare',
    subCategory: 'Serum',
    description:
        'A high-strength vitamin and mineral blemish formula that targets uneven skin tone, enlarged pores, and oiliness. '
        'The combination of 10% niacinamide with zinc salt of pyrrolidone carboxylic acid visibly reduces blemishes and balances sebum production. '
        'Lightweight and water-based, it layers seamlessly under moisturizers and SPF.',
    howToUse:
        'Apply a few drops to cleansed skin in the morning and evening before moisturizer. '
        'Avoid using with vitamin C serums in the same routine as they may reduce efficacy. '
        'Patch test recommended for first-time users.',
    price: 599,
    originalPrice: 799,
    rating: 4.6,
    reviewCount: 583,
    dermiqMatchScore: 92,
    accentColor: Color(0xFF7C5CFF),
    benefits: [
      'Minimises pore appearance',
      'Controls sebum production',
      'Evens skin tone',
    ],
    ingredients: [
      'Niacinamide (10%)',
      'Zinc PCA (1%)',
      'Tamarindus Indica Seed Gum',
      'Xanthan Gum',
      'Isoceteth-20',
    ],
    skinTypes: ['Oily', 'Combination', 'Acne-Prone'],
    concerns: ['Acne', 'Large Pores', 'Oiliness', 'Uneven Tone'],
    isFeatured: true,
  ),

  ShopProduct(
    id: 'sk004',
    name: 'Anthelios UVMune 400 SPF 50+ Sunscreen',
    brand: 'La Roche-Posay',
    category: 'Skincare',
    subCategory: 'Sunscreen',
    description:
        'An advanced broad-spectrum sunscreen offering superior UVA/UVB protection with the exclusive Mexoryl 400 filter technology. '
        'The fluid, non-greasy texture is water-resistant and leaves a barely-there finish suitable for all skin types, including sensitive. '
        'Tested under dermatological supervision and formulated without parabens or fragrance.',
    howToUse:
        'Apply generously to face and neck 15 minutes before sun exposure. '
        'Reapply every two hours during prolonged outdoor activity or after swimming or sweating. '
        'Use as the final step of your morning skincare routine.',
    price: 1299,
    originalPrice: 1599,
    rating: 4.9,
    reviewCount: 421,
    dermiqMatchScore: 97,
    accentColor: Color(0xFFF59E0B),
    benefits: [
      'Broad-spectrum UVA/UVB protection',
      'Water-resistant formula',
      'Non-greasy invisible finish',
    ],
    ingredients: [
      'Mexoryl 400',
      'Mexoryl SX',
      'Tinosorb S',
      'Octinoxate',
      'Thermal Spring Water',
      'Glycerin',
    ],
    skinTypes: ['All Skin Types', 'Sensitive'],
    concerns: ['Sun Damage', 'Hyperpigmentation', 'Premature Ageing'],
    isFeatured: true,
  ),

  ShopProduct(
    id: 'sk005',
    name: 'Retinol 0.3% in Squalane',
    brand: 'Minimalist',
    category: 'Skincare',
    subCategory: 'Treatment',
    description:
        'A beginner-friendly retinol serum suspended in squalane for minimised irritation while delivering visible anti-ageing results. '
        '0.3% pure retinol stimulates cell turnover and collagen synthesis to improve fine lines, texture, and uneven skin tone over time. '
        'Formulated without added fragrance, it is a great entry-point into retinoid therapy.',
    howToUse:
        'Use only at night, 2–3 times a week when starting out. '
        'Apply 3–4 drops to cleansed, dry skin and follow with a moisturizer. '
        'Always use broad-spectrum SPF in the morning when using retinol.',
    price: 499,
    originalPrice: 649,
    rating: 4.5,
    reviewCount: 368,
    dermiqMatchScore: 82,
    accentColor: Color(0xFFEC4899),
    benefits: [
      'Reduces fine lines and wrinkles',
      'Improves skin texture',
      'Promotes cell renewal',
    ],
    ingredients: [
      'Retinol (0.3%)',
      'Squalane',
      'BHT',
      'Ethyl Linoleate',
      'Tocopherol',
    ],
    skinTypes: ['Normal', 'Combination', 'Dry'],
    concerns: ['Fine Lines', 'Ageing', 'Uneven Texture'],
    isFeatured: false,
  ),

  ShopProduct(
    id: 'sk006',
    name: '15% Vitamin C Face Serum',
    brand: 'Dot & Key',
    category: 'Skincare',
    subCategory: 'Serum',
    description:
        'A potent brightening serum powered by stable 15% ethyl ascorbic acid that visibly fades dark spots and boosts radiance in as little as two weeks. '
        'Enriched with ferulic acid and niacinamide, it provides antioxidant protection while evening out skin tone. '
        'The lightweight, fast-absorbing formula is suitable for most skin types and works well layered under moisturiser and SPF.',
    howToUse:
        'Apply 3–4 drops to cleansed skin every morning before moisturiser and sunscreen. '
        'Avoid direct contact with eyes. '
        'For best results, use consistently as part of your AM routine.',
    price: 899,
    originalPrice: 1199,
    rating: 4.4,
    reviewCount: 294,
    dermiqMatchScore: 85,
    accentColor: Color(0xFFF97316),
    benefits: [
      'Visibly fades dark spots',
      'Boosts skin radiance',
      'Antioxidant protection',
    ],
    ingredients: [
      'Ethyl Ascorbic Acid (15%)',
      'Niacinamide',
      'Ferulic Acid',
      'Hyaluronic Acid',
      'Panthenol',
    ],
    skinTypes: ['Normal', 'Oily', 'Combination', 'Dull'],
    concerns: ['Dark Spots', 'Hyperpigmentation', 'Dullness'],
    isFeatured: false,
  ),

  // ─── HAIRCARE ────────────────────────────────────────────────────────────

  ShopProduct(
    id: 'hc001',
    name: 'Apple Cider Vinegar Shampoo',
    brand: 'WOW Skin Science',
    category: 'Haircare',
    subCategory: 'Shampoo',
    description:
        'A sulphate-free clarifying shampoo infused with raw apple cider vinegar that gently removes product build-up and scalp impurities. '
        'Enriched with argan oil and sweet almond oil, it cleanses without stripping moisture, leaving hair soft, shiny, and manageable. '
        'Free from parabens, sulphates, and silicones, it is safe for colour-treated hair.',
    howToUse:
        'Wet hair thoroughly and apply an adequate amount to the scalp. '
        'Massage gently to create a light lather, working down to the ends. '
        'Rinse well and follow with conditioner.',
    price: 349,
    originalPrice: 499,
    rating: 4.3,
    reviewCount: 512,
    dermiqMatchScore: 88,
    accentColor: Color(0xFF84CC16),
    benefits: [
      'Removes scalp build-up',
      'Adds shine and manageability',
      'Sulphate & paraben free',
    ],
    ingredients: [
      'Apple Cider Vinegar',
      'Argan Oil',
      'Sweet Almond Oil',
      'Pro-Vitamin B5',
      'Nettle Leaf Extract',
    ],
    hairTypes: ['All Hair Types', 'Colour-Treated', 'Oily Scalp'],
    concerns: ['Product Build-Up', 'Dullness', 'Frizz'],
    isFeatured: false,
  ),

  ShopProduct(
    id: 'hc002',
    name: 'Onion Black Seed Hair Oil',
    brand: 'Mamaearth',
    category: 'Haircare',
    subCategory: 'Hair Oil',
    description:
        'A nourishing hair oil combining the power of onion oil and black seed oil to reduce hair fall and promote stronger, thicker hair growth. '
        'Infused with redensyl, it actively stimulates dormant hair follicles while deeply conditioning the scalp. '
        'Certified toxin-free and dermatologically tested, it is suitable for all hair types.',
    howToUse:
        'Warm the oil slightly and apply to the scalp section by section. '
        'Massage gently using fingertips for 5–10 minutes to improve blood circulation. '
        'Leave for at least one hour or overnight before washing off with a mild shampoo.',
    price: 399,
    originalPrice: 549,
    rating: 4.5,
    reviewCount: 687,
    dermiqMatchScore: 91,
    accentColor: Color(0xFFD97706),
    benefits: [
      'Reduces hair fall significantly',
      'Promotes hair growth',
      'Deeply nourishes scalp',
    ],
    ingredients: [
      'Onion Bulb Oil',
      'Black Seed (Kalonji) Oil',
      'Redensyl',
      'Bhringraj Extract',
      'Castor Oil',
      'Coconut Oil',
    ],
    hairTypes: ['All Hair Types', 'Thin Hair', 'Damaged Hair'],
    concerns: ['Hair Fall', 'Thinning Hair', 'Scalp Dryness'],
    isFeatured: true,
  ),

  ShopProduct(
    id: 'hc003',
    name: 'Total Repair 5 Damage-Erasing Balm',
    brand: "L'Oréal Paris",
    category: 'Haircare',
    subCategory: 'Hair Mask',
    description:
        'An intensive 5-in-1 repair hair mask that targets the five signs of hair damage: dryness, roughness, dullness, brittleness, and split ends. '
        'Enriched with ceramides and pro-keratin complex, it reconstructs damaged hair fibres from within for visibly smoother, stronger hair. '
        'Just one use delivers up to 24-hour smoothness with long-lasting protection.',
    howToUse:
        'After shampooing, apply generously from mid-lengths to ends on wet hair. '
        'Leave on for 3–5 minutes, then rinse thoroughly. '
        'Use 1–2 times a week for best results.',
    price: 549,
    originalPrice: 699,
    rating: 4.4,
    reviewCount: 328,
    dermiqMatchScore: 86,
    accentColor: Color(0xFFEF4444),
    benefits: [
      'Repairs 5 signs of damage',
      'Restores smoothness and shine',
      'Strengthens hair from within',
    ],
    ingredients: [
      'Pro-Keratin Complex',
      'Ceramide R',
      'Arginine',
      'Lactic Acid',
      'Hydrolysed Protein',
    ],
    hairTypes: ['Damaged', 'Dry', 'Chemically Treated', 'Colour-Treated'],
    concerns: ['Hair Damage', 'Dryness', 'Frizz', 'Split Ends'],
    isFeatured: false,
  ),

  ShopProduct(
    id: 'hc004',
    name: 'Bringha Anti-Hairfall Shampoo',
    brand: 'Indulekha',
    category: 'Haircare',
    subCategory: 'Shampoo',
    description:
        'An Ayurvedic anti-hairfall shampoo powered by the unique Bringharaj (Bhringraj) herb blended with Svetakutaja, neem, and amla. '
        'Clinically proven to reduce hair fall by up to 40% in 4 weeks with regular use. '
        'Sulphate-free and gentle enough for daily cleansing, it leaves hair feeling clean, nourished, and visibly thicker.',
    howToUse:
        'Apply to wet hair and scalp and lather well for 2–3 minutes. '
        'Rinse thoroughly with water. '
        'Follow with Indulekha conditioner for best results.',
    price: 349,
    originalPrice: 449,
    rating: 4.6,
    reviewCount: 461,
    dermiqMatchScore: 89,
    accentColor: Color(0xFF059669),
    benefits: [
      'Clinically reduces hair fall',
      'Strengthens hair from roots',
      'Ayurvedic herbal formula',
    ],
    ingredients: [
      'Bhringraj (Eclipta Alba) Extract',
      'Svetakutaja Extract',
      'Neem Extract',
      'Amla (Emblica Officinalis)',
      'Coconut-derived Surfactants',
    ],
    hairTypes: ['All Hair Types', 'Thinning Hair', 'Normal to Oily Scalp'],
    concerns: ['Hair Fall', 'Weak Roots', 'Scalp Health'],
    isFeatured: true,
  ),

  ShopProduct(
    id: 'hc005',
    name: 'Anti-Hair Fall Serum',
    brand: 'Himalaya',
    category: 'Haircare',
    subCategory: 'Hair Serum',
    description:
        'A leave-in hair serum with a concentrated blend of natural botanicals that targets hair fall at the root cause. '
        'Protein Hydrolysate and Winter Cherry (Ashwagandha) work synergistically to strengthen hair follicles and reduce breakage. '
        'Lightweight and non-sticky, it can be used daily without weighing hair down.',
    howToUse:
        'Apply a small amount to towel-dried or dry hair, focusing on the scalp and roots. '
        'Massage gently for 2–3 minutes. '
        'Do not rinse out. Style as usual.',
    price: 299,
    originalPrice: 399,
    rating: 4.1,
    reviewCount: 183,
    dermiqMatchScore: 84,
    accentColor: Color(0xFF6366F1),
    benefits: [
      'Reduces breakage and split ends',
      'Strengthens hair follicles',
      'Lightweight leave-in formula',
    ],
    ingredients: [
      'Protein Hydrolysate',
      'Winter Cherry (Ashwagandha) Extract',
      'Bhringraj Extract',
      'Olive Oil',
      'Panthenol',
    ],
    hairTypes: ['All Hair Types', 'Fine Hair', 'Brittle Hair'],
    concerns: ['Hair Fall', 'Breakage', 'Weak Hair'],
    isFeatured: false,
  ),

  ShopProduct(
    id: 'hc006',
    name: 'Japapatti Brahmi Hair Elixir',
    brand: 'Forest Essentials',
    category: 'Haircare',
    subCategory: 'Hair Oil',
    description:
        'A luxurious Ayurvedic hair elixir formulated with twelve sacred herbs macerated in cold-pressed sesame oil, following traditional recipes from the Charaka Samhita. '
        'Brahmi, Japapatti (Hibiscus), and Bhringraj deeply nourish the scalp to stimulate hair growth, prevent premature greying, and add natural lustre. '
        'Hand-crafted in small batches without mineral oils or artificial fragrance, it is a truly holistic hair treatment.',
    howToUse:
        'Warm a few drops between palms and apply to the scalp and hair lengths. '
        'Part hair in sections and massage the scalp in circular motions for 10–15 minutes. '
        'Leave overnight for maximum absorption and wash off the next morning.',
    price: 1249,
    originalPrice: 1599,
    rating: 4.7,
    reviewCount: 97,
    dermiqMatchScore: 93,
    accentColor: Color(0xFF9333EA),
    benefits: [
      'Deep Ayurvedic scalp nourishment',
      'Prevents premature greying',
      'Promotes thick, lustrous growth',
    ],
    ingredients: [
      'Cold-Pressed Sesame Oil',
      'Brahmi (Bacopa Monnieri) Extract',
      'Hibiscus (Japapatti) Extract',
      'Bhringraj Extract',
      'Amla Extract',
      'Methi (Fenugreek) Extract',
    ],
    hairTypes: ['All Hair Types', 'Dry Hair', 'Damaged Hair'],
    concerns: ['Hair Fall', 'Premature Greying', 'Scalp Dryness'],
    isFeatured: true,
  ),
];

List<ShopProduct> get skincare =>
    shopProducts.where((p) => p.category == 'Skincare').toList();

List<ShopProduct> get haircare =>
    shopProducts.where((p) => p.category == 'Haircare').toList();
