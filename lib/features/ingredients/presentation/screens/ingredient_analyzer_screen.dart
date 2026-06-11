import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

class IngredientAnalyzerScreen extends StatefulWidget {
  const IngredientAnalyzerScreen({super.key});

  @override
  State<IngredientAnalyzerScreen> createState() =>
      _IngredientAnalyzerScreenState();
}

class _IngredientAnalyzerScreenState extends State<IngredientAnalyzerScreen> {
  final _controller = TextEditingController();
  bool _isAnalyzing = false;
  _AnalysisResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _result = _AnalysisResult(
        name: _controller.text.trim(),
        rating: 'Generally Safe',
        ratingColor: AppColors.success,
        benefits: [
          'Brightens skin tone',
          'Antioxidant protection',
          'Reduces hyperpigmentation',
          'Supports collagen synthesis',
        ],
        warnings: [
          'Can cause irritation at high concentrations',
          'May oxidize — store in dark, cool place',
          'Avoid mixing with Niacinamide directly',
        ],
        usage: 'Apply 2-3 drops in the morning before moisturizer. Always follow with SPF.',
        compatibility: [
          _Compat('Hyaluronic Acid', true),
          _Compat('Ferulic Acid', true),
          _Compat('Niacinamide', false),
          _Compat('Retinol', false),
          _Compat('AHA/BHA', false),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(title: const Text('Ingredient Analyzer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter an ingredient to analyze',
                    style: AppTypography.labelMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'e.g. Niacinamide, Retinol, Vitamin C...',
                      prefixIcon: Icon(Icons.science_outlined,
                          color: context.dColors.textSecondary),
                    ),
                    onSubmitted: (_) => _analyze(),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Analyze',
                    isLoading: _isAnalyzing,
                    onPressed: _analyze,
                  ),
                ],
              ),
            ),

            // Popular ingredients
            if (_result == null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              Text('Popular Ingredients', style: AppTypography.h4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Retinol',
                  'Niacinamide',
                  'Vitamin C',
                  'Hyaluronic Acid',
                  'Salicylic Acid',
                  'Ceramides',
                  'Peptides',
                  'Glycolic Acid',
                ]
                    .map((ing) => GestureDetector(
                          onTap: () {
                            _controller.text = ing;
                            _analyze();
                          },
                          child: Chip(
                            label: Text(ing),
                            backgroundColor:
                                AppColors.lavender.withValues(alpha: 0.08),
                            labelStyle: AppTypography.caption
                                .copyWith(color: AppColors.primary),
                            side: BorderSide(
                                color: AppColors.lavender.withValues(alpha: 0.2)),
                          ),
                        ))
                    .toList(),
              ),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultView(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Compat {
  final String ingredient;
  final bool compatible;
  const _Compat(this.ingredient, this.compatible);
}

class _AnalysisResult {
  final String name;
  final String rating;
  final Color ratingColor;
  final List<String> benefits;
  final List<String> warnings;
  final String usage;
  final List<_Compat> compatibility;

  const _AnalysisResult({
    required this.name,
    required this.rating,
    required this.ratingColor,
    required this.benefits,
    required this.warnings,
    required this.usage,
    required this.compatibility,
  });
}

class _ResultView extends StatelessWidget {
  final _AnalysisResult result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.science_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.name,
                        style: AppTypography.h4.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: result.ratingColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(result.rating,
                          style: AppTypography.caption
                              .copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text('Benefits', style: AppTypography.h4),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: result.benefits
                .map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(b, style: AppTypography.bodyMedium)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 20),
        Text('How to Use', style: AppTypography.h4),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Text(result.usage, style: AppTypography.bodyMedium),
        ),

        const SizedBox(height: 20),
        Text('Warnings', style: AppTypography.h4),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: result.warnings
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(w, style: AppTypography.bodyMedium)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 20),
        Text('Compatibility', style: AppTypography.h4),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: result.compatibility
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(
                            c.compatible
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: c.compatible
                                ? AppColors.success
                                : AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(c.ingredient,
                                style: AppTypography.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            c.compatible ? 'Works well' : 'Avoid mixing',
                            style: AppTypography.caption.copyWith(
                              color: c.compatible
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
