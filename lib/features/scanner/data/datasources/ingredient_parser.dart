import '../../domain/entities/scanned_ingredient.dart';

/// Turns raw OCR text from an INCI panel into classified [ScannedIngredient]s.
///
/// The classification dictionary is intentionally small and lives here so it
/// can be swapped for a remote ingredient-safety API without touching the rest
/// of the architecture.
class IngredientParser {
  const IngredientParser();

  /// Known function + safety for common cosmetic ingredients (lowercased keys).
  static const Map<String, ({String fn, IngredientSafety safety, String? note})>
      _dictionary = {
    'aqua': (fn: 'Solvent', safety: IngredientSafety.safe, note: null),
    'water': (fn: 'Solvent', safety: IngredientSafety.safe, note: null),
    'glycerin': (fn: 'Humectant', safety: IngredientSafety.safe, note: null),
    'niacinamide': (fn: 'Brightening', safety: IngredientSafety.safe, note: null),
    'hyaluronic acid': (fn: 'Humectant', safety: IngredientSafety.safe, note: null),
    'sodium hyaluronate': (fn: 'Humectant', safety: IngredientSafety.safe, note: null),
    'ceramide np': (fn: 'Barrier repair', safety: IngredientSafety.safe, note: null),
    'panthenol': (fn: 'Soothing', safety: IngredientSafety.safe, note: null),
    'squalane': (fn: 'Emollient', safety: IngredientSafety.safe, note: null),
    'tocopherol': (fn: 'Antioxidant', safety: IngredientSafety.safe, note: null),
    'retinol': (
      fn: 'Anti-aging',
      safety: IngredientSafety.caution,
      note: 'Use at night with SPF; can irritate sensitive skin.'
    ),
    'salicylic acid': (
      fn: 'Exfoliant (BHA)',
      safety: IngredientSafety.caution,
      note: 'Avoid overuse; increases sun sensitivity.'
    ),
    'glycolic acid': (
      fn: 'Exfoliant (AHA)',
      safety: IngredientSafety.caution,
      note: 'Pair with SPF; may sting on broken skin.'
    ),
    'fragrance': (
      fn: 'Fragrance',
      safety: IngredientSafety.caution,
      note: 'Common irritant/allergen for sensitive skin.'
    ),
    'parfum': (
      fn: 'Fragrance',
      safety: IngredientSafety.caution,
      note: 'Common irritant/allergen for sensitive skin.'
    ),
    'denatured alcohol': (
      fn: 'Solvent',
      safety: IngredientSafety.caution,
      note: 'Can be drying in high concentration.'
    ),
    'sodium lauryl sulfate': (
      fn: 'Surfactant',
      safety: IngredientSafety.avoid,
      note: 'Harsh; strips the skin barrier.'
    ),
    'methylparaben': (
      fn: 'Preservative',
      safety: IngredientSafety.avoid,
      note: 'Paraben — many users prefer to avoid.'
    ),
    'oxybenzone': (
      fn: 'UV filter',
      safety: IngredientSafety.avoid,
      note: 'Reef-harming; possible hormone disruptor.'
    ),
  };

  List<ScannedIngredient> parse(String rawText) {
    if (rawText.trim().isEmpty) return const [];

    // Strip a leading "Ingredients:" header if present.
    var text = rawText.replaceAll('\n', ' ');
    final headerMatch =
        RegExp(r'ingredients?\s*[:\-]', caseSensitive: false).firstMatch(text);
    if (headerMatch != null) {
      text = text.substring(headerMatch.end);
    }

    final tokens = text
        .split(RegExp(r'[,•·;]'))
        .map(_clean)
        .where((t) => t.length > 1 && t.length < 60)
        .toList();

    final seen = <String>{};
    final result = <ScannedIngredient>[];
    for (final token in tokens) {
      final key = token.toLowerCase();
      if (!seen.add(key)) continue; // dedupe
      final known = _dictionary[key];
      result.add(ScannedIngredient(
        name: _titleCase(token),
        function: known?.fn,
        safety: known?.safety ?? IngredientSafety.unknown,
        note: known?.note,
      ));
    }
    return result;
  }

  String _clean(String s) => s
      .replaceAll(RegExp(r'[^A-Za-z0-9 \-]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');
}
