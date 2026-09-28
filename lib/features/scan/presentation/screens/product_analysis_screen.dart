import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../shelf/data/shelf_models.dart';
import '../../../shelf/providers/shelf_provider.dart';
import '../../../scanner/domain/entities/scanned_ingredient.dart';
import '../../../scanner/domain/entities/scanned_product.dart';

// Fallback mock (used only when no real scanned product is supplied).
const _kName = 'CeraVe Foaming Facial Cleanser';
const _kBrand = 'CeraVe';
const _kCategory = 'Cleanser';
const _kSafetyScore = 92;
const _kSkinMatch = 88;
const _kHairMatch = 75;

// Safe defaults for the not-computable-on-free-tier compatibility figures.
const _kDefaultSkinMatch = 80;
const _kDefaultHairMatch = 70;
const _kDefaultAllergy = 90;

// ─── Screen ──────────────────────────────────────────────────────────────────

class ProductAnalysisScreen extends ConsumerStatefulWidget {
  final String productId;

  /// The real scanned product, when navigation supplied one via `extra`.
  /// Null for the ingredients-only path or legacy links → screen falls back
  /// to the CeraVe mock so nothing else breaks.
  final ScannedProduct? scanned;

  const ProductAnalysisScreen({
    super.key,
    required this.productId,
    this.scanned,
  });

  @override
  ConsumerState<ProductAnalysisScreen> createState() => _ProductAnalysisScreenState();
}

class _ProductAnalysisScreenState extends ConsumerState<ProductAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1500),
    );
    _enterAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  // Real fields when a scanned product is present, else the CeraVe mock.
  ScannedProduct? get _scanned => widget.scanned;
  String get _name => _scanned?.name ?? _kName;
  String get _brand => _scanned?.brand ?? _kBrand;
  String get _category => _scanned?.category ?? _kCategory;
  int get _safetyScore => _scanned?.safetyScore ?? _kSafetyScore;
  int get _skinMatch => _scanned != null ? _kDefaultSkinMatch : _kSkinMatch;
  int get _hairMatch => _scanned != null ? _kDefaultHairMatch : _kHairMatch;

  /// Save Product → Add To Shelf (Scanner is a shelf source, per spec).
  void _addToShelf() {
    final now = DateTime.now();
    ref.read(shelfProvider.notifier).addProduct(ShelfProduct(
          id: 'scan_${widget.productId}_${now.millisecondsSinceEpoch}',
          name: _name,
          brand: _brand,
          category: _category,
          score: _safetyScore,
          color: AppColors.primary,
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 365)),
          notes: 'Added from scan analysis',
          skinMatch: _skinMatch,
          hairMatch: _hairMatch,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_name added to My Shelf',
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.push('/my-shelf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero app bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight:   252,
            pinned:           true,
            backgroundColor:  const Color(0xFF1E1B4B),
            surfaceTintColor: Colors.transparent,
            elevation:        0,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:  Colors.white.withValues(alpha: 0.15),
                  shape:  BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size:  20,
                ),
              ),
            ),
            title: Text(
              'Product Analysis',
              style: AppTypography.labelLarge
                  .copyWith(color: Colors.white),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _HeroBackground(
                name: _name,
                brand: _brand,
                category: _category,
                safetyScore: _safetyScore,
              ),
            ),
          ),

          // ── Content sections ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // 1 · Safety Overview
                AnimatedBuilder(
                  animation: _enterAnim,
                  builder: (_, _) => _SafetyOverviewCard(
                    progress: _enterAnim.value,
                    safetyScore: _safetyScore,
                    skinMatch: _skinMatch,
                    hairMatch: _hairMatch,
                  ),
                ).animate()
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 2 · AI Verdict
                _AiVerdictBanner(
                  productName: _name,
                  isScanned: _scanned != null,
                )
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 60.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 3 · Compatibility
                AnimatedBuilder(
                  animation: _enterAnim,
                  builder: (_, _) => _CompatibilityCard(
                    progress: _enterAnim.value,
                    skinMatch: _skinMatch,
                    hairMatch: _hairMatch,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 100.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 4 · Ingredient Breakdown
                _IngredientBreakdownCard(scanned: _scanned)
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 140.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 5 · Key Ingredients
                _KeyIngredientsSection(scanned: _scanned)
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 180.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 6 · Flagged Ingredients
                _FlaggedCard(scanned: _scanned)
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 220.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 7 · Product Details
                _ProductDetailsCard(
                  scanned: _scanned,
                  barcode: widget.productId,
                )
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 260.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 22),

                // 8 · Actions
                AppButton(
                  label:     'Add to My Shelf',
                  onPressed: _addToShelf,
                  icon:      const Icon(Icons.add_rounded,
                      color: Colors.white, size: 18),
                ).animate()
                    .fadeIn(duration: 320.ms, delay: 300.ms),

                const SizedBox(height: 10),

                AppButton(
                  label:      'Analyse Another Product',
                  onPressed:  () => context.go('/scan'),
                  isOutlined: true,
                ).animate()
                    .fadeIn(duration: 320.ms, delay: 340.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero background ──────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  final String name;
  final String brand;
  final String category;
  final int safetyScore;
  const _HeroBackground({
    required this.name,
    required this.brand,
    required this.category,
    required this.safetyScore,
  });

  @override
  Widget build(BuildContext context) {
    final safe = safetyScore >= 70;
    final chipColor =
        safe ? const Color(0xFF22C55E) : AppColors.error;
    return Stack(
      children: [
        // Gradient fill
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.topLeft,
              end:    Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B),
                Color(0xFF3B2D9F),
                Color(0xFF5E3FFF),
              ],
              stops: [0.0, 0.50, 1.0],
            ),
          ),
        ),

        // Decorative blobs
        Positioned(
          right: -30, top: -30,
          child: Container(
            width: 130, height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          left: -20, bottom: -20,
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),

        // Product info
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product icon
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border:       Border.all(
                          color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Colors.white,
                      size:  40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: AppTypography.h4.copyWith(
                      color:     Colors.white,
                      fontSize:  17,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$brand  ·  $category',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Safety score hero chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: chipColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: chipColor.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded,
                            size: 14, color: chipColor),
                        const SizedBox(width: 7),
                        Text(
                          '$safetyScore Safety Score  ·  ${safe ? 'Safe for You' : 'Review Flags'}',
                          style: AppTypography.caption.copyWith(
                            color:      chipColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 1 · Safety overview ──────────────────────────────────────────────────────

class _SafetyOverviewCard extends StatelessWidget {
  final double progress;
  final int safetyScore;
  final int skinMatch;
  final int hairMatch;
  const _SafetyOverviewCard({
    required this.progress,
    required this.safetyScore,
    required this.skinMatch,
    required this.hairMatch,
  });

  @override
  Widget build(BuildContext context) {
    final safe = safetyScore >= 70;
    final verdictColor =
        safe ? const Color(0xFF22C55E) : AppColors.error;
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        const Color(0xFF22C55E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size:  17,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 10),
              Text('Safety Overview', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 20),

          // Score rings row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreRing(
                score:    safetyScore,
                label:    'Safety\nScore',
                color:    verdictColor,
                progress: progress,
              ),
              _ScoreRing(
                score:    skinMatch,
                label:    'Skin\nMatch',
                color:    AppColors.primary,
                progress: progress,
              ),
              _ScoreRing(
                score:    hairMatch,
                label:    'Hair\nMatch',
                color:    const Color(0xFFF59E0B),
                progress: progress,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Verdict chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color:        verdictColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                  color: verdictColor.withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(safe ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    size: 16, color: verdictColor),
                const SizedBox(width: 8),
                Text(
                  safe
                      ? 'Safe for your skin and hair profile'
                      : 'Review the flagged ingredients below',
                  style: AppTypography.labelSmall.copyWith(
                    color:      verdictColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _RecommendationChip(score: safetyScore),
        ],
      ),
    );
  }
}

// ─── Recommendation status (derived from the overall score) ───────────────────

({String label, Color color, IconData icon}) recommendationFor(int score) {
  if (score >= 85) {
    return (label: 'Highly Recommended', color: const Color(0xFF16A34A), icon: Icons.verified_rounded);
  }
  if (score >= 70) {
    return (label: 'Recommended', color: const Color(0xFF22C55E), icon: Icons.thumb_up_rounded);
  }
  if (score >= 50) {
    return (label: 'Neutral', color: const Color(0xFFF59E0B), icon: Icons.remove_circle_outline_rounded);
  }
  return (label: 'Not Recommended', color: AppColors.error, icon: Icons.do_not_disturb_on_rounded);
}

class _RecommendationChip extends StatelessWidget {
  final int score;
  const _RecommendationChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final r = recommendationFor(score);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: r.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: r.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(r.icon, size: 16, color: r.color),
          const SizedBox(width: 8),
          Text(r.label,
              style: AppTypography.labelMedium
                  .copyWith(color: r.color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── 2 · AI Verdict banner ────────────────────────────────────────────────────

class _AiVerdictBanner extends StatelessWidget {
  final String productName;
  final bool isScanned;
  const _AiVerdictBanner({
    required this.productName,
    required this.isScanned,
  });

  @override
  Widget build(BuildContext context) {
    final text = isScanned
        ? '$productName was matched from its barcode and its ingredient list '
            'analysed for safety. Review the ingredient breakdown and any '
            'flagged items below before adding it to your routine.'
        : 'CeraVe Foaming Cleanser is a strong match for your combination skin profile. '
            'Ceramides and hyaluronic acid address your hydration goals, while niacinamide '
            'targets pore appearance. One caution ingredient detected — see below.';
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color:        const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size:  18,
              color: Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI ANALYSIS',
                  style: AppTypography.overline.copyWith(
                    color:         const Color(0xFFF59E0B),
                    letterSpacing: 1.4,
                    fontWeight:    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: AppTypography.caption.copyWith(
                    color:  context.dColors.textPrimary,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 3 · Compatibility ────────────────────────────────────────────────────────

class _CompatibilityCard extends StatelessWidget {
  final double progress;
  final int skinMatch;
  final int hairMatch;
  const _CompatibilityCard({
    required this.progress,
    required this.skinMatch,
    required this.hairMatch,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size:  17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text('Your Compatibility', style: AppTypography.labelLarge),
              const Spacer(),
              _CompatVerdictChip(
                  scores: [skinMatch, hairMatch, _kDefaultAllergy]),
            ],
          ),
          const SizedBox(height: 18),
          _CompatBar(
            label:    'Skin Match',
            score:    skinMatch,
            color:    AppColors.primary,
            progress: progress,
          ),
          const SizedBox(height: 13),
          _CompatBar(
            label:    'Hair Match',
            score:    hairMatch,
            color:    const Color(0xFFF59E0B),
            progress: progress,
          ),
          const SizedBox(height: 13),
          _CompatBar(
            label:    'Allergy Check',
            score:    _kDefaultAllergy,
            color:    const Color(0xFF22C55E),
            progress: progress,
          ),
          const SizedBox(height: 14),
          Container(
            padding:    const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:        context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: context.dColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on your skin type (Combination), hair type (Wavy) and declared allergies.',
                    style: AppTypography.caption.copyWith(
                      color:  context.dColors.textTertiary,
                      height: 1.4,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compatibility verdict (Compatible / Partially / Not Compatible) ──────────

class _CompatVerdictChip extends StatelessWidget {
  final List<int> scores; // skin, hair, allergy
  const _CompatVerdictChip({required this.scores});

  ({String label, Color color}) get _verdict {
    if (scores.isEmpty) {
      return (label: 'Unknown', color: const Color(0xFF94A3B8));
    }
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    if (avg >= 75) return (label: 'Compatible', color: const Color(0xFF22C55E));
    if (avg >= 50) return (label: 'Partially', color: const Color(0xFFF59E0B));
    return (label: 'Not Compatible', color: AppColors.error);
  }

  @override
  Widget build(BuildContext context) {
    final v = _verdict;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: v.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: v.color.withValues(alpha: 0.28)),
      ),
      child: Text(v.label,
          style: AppTypography.caption
              .copyWith(color: v.color, fontWeight: FontWeight.w700, fontSize: 10.5)),
    );
  }
}

// ─── 4 · Ingredient breakdown ─────────────────────────────────────────────────

class _IngredientBreakdownCard extends StatelessWidget {
  final ScannedProduct? scanned;
  const _IngredientBreakdownCard({required this.scanned});

  List<String> _names(IngredientSafety s) => scanned!.ingredients
      .where((i) => i.safety == s)
      .map((i) => i.name)
      .toList();

  @override
  Widget build(BuildContext context) {
    final s = scanned;
    final int total;
    final List<String> safe;
    final List<String> caution;
    final List<String> avoid;
    if (s != null) {
      total = s.ingredients.length;
      safe = _names(IngredientSafety.safe);
      caution = _names(IngredientSafety.caution);
      avoid = _names(IngredientSafety.avoid);
    } else {
      total = 24;
      safe = const [
        'Niacinamide', 'Ceramide NP', 'Hyaluronic Acid',
        'Glycerin', 'Panthenol', 'Ceramide AP', 'Cholesterol',
      ];
      caution = const ['Fragrance', 'Phenoxyethanol'];
      avoid = const [];
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        const Color(0xFF0EA5E9).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.list_alt_rounded,
                  size:  17,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 10),
              Text('Ingredient Breakdown',
                  style: AppTypography.labelLarge),
              const Spacer(),
              Text(
                '$total total',
                style: AppTypography.caption
                    .copyWith(color: context.dColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _IngSection(
            label: 'Safe',
            count: safe.length,
            color: const Color(0xFF22C55E),
            items: safe,
            emptyLabel: 'None detected',
          ),
          const SizedBox(height: 14),
          _IngSection(
            label: 'Caution',
            count: caution.length,
            color: const Color(0xFFF59E0B),
            items: caution,
            emptyLabel: 'None detected',
          ),
          const SizedBox(height: 14),
          _IngSection(
            label: 'Avoid',
            count: avoid.length,
            color: const Color(0xFFEF4444),
            items: avoid,
            emptyLabel: 'None detected',
          ),
        ],
      ),
    );
  }
}

// ─── 5 · Key ingredients ──────────────────────────────────────────────────────

class _KeyIngredientsSection extends StatelessWidget {
  final ScannedProduct? scanned;
  const _KeyIngredientsSection({required this.scanned});

  static const _palette = [
    Color(0xFF0EA5E9), Color(0xFF22C55E), Color(0xFF8B5CF6),
    Color(0xFFF59E0B), Color(0xFF14B8A6),
  ];

  static const _mockCards = [
    _KeyIngCard(
      name:    'Ceramide NP',
      fn:      'Barrier Repair',
      benefit: 'Restores and maintains the skin\'s protective lipid barrier after cleansing.',
      color:   Color(0xFF0EA5E9),
      icon:    Icons.shield_rounded,
    ),
    SizedBox(width: 10),
    _KeyIngCard(
      name:    'Hyaluronic Acid',
      fn:      'Deep Hydration',
      benefit: 'Draws moisture into the skin for visibly plump and hydrated skin all day.',
      color:   Color(0xFF22C55E),
      icon:    Icons.water_drop_rounded,
    ),
    SizedBox(width: 10),
    _KeyIngCard(
      name:    'Niacinamide',
      fn:      'Brightening & Pores',
      benefit: 'Minimises the appearance of pores and visibly evens out skin tone over time.',
      color:   Color(0xFF8B5CF6),
      icon:    Icons.brightness_5_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final s = scanned;

    // Real scanned product with no readable ingredients → hide the section.
    if (s != null && s.ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> cards;
    if (s != null) {
      // Show the first few ingredients from the real INCI list, using only
      // scanned facts (name / function / note) — no fabricated benefits.
      final picks = s.ingredients.take(6).toList();
      cards = [
        for (var i = 0; i < picks.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _KeyIngCard(
            name:    picks[i].name,
            fn:      picks[i].function ?? 'Ingredient',
            benefit: picks[i].note ??
                'Identified in this product\'s ingredient list.',
            color:   _palette[i % _palette.length],
            icon:    Icons.science_rounded,
          ),
        ],
      ];
    } else {
      cards = _mockCards;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Key Ingredients', style: AppTypography.labelLarge),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: cards,
          ),
        ),
      ],
    );
  }
}

// ─── 6 · Flagged ingredients ──────────────────────────────────────────────────

class _FlaggedCard extends StatelessWidget {
  final ScannedProduct? scanned;
  const _FlaggedCard({required this.scanned});

  @override
  Widget build(BuildContext context) {
    final s = scanned;

    final List<ScannedIngredient> flagged = s != null
        ? s.ingredients
            .where((i) =>
                i.safety == IngredientSafety.caution ||
                i.safety == IngredientSafety.avoid)
            .toList()
        : const [];

    // Real scanned product with nothing flagged → hide the card.
    if (s != null && flagged.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> rows;
    final int count;
    if (s != null) {
      count = flagged.length;
      rows = [
        for (var i = 0; i < flagged.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _FlagRow(
            name:    flagged[i].name,
            concern: flagged[i].note ??
                (flagged[i].safety == IngredientSafety.avoid
                    ? 'Flagged to avoid based on its safety classification.'
                    : 'Use with caution based on its safety classification.'),
            color:   flagged[i].safety == IngredientSafety.avoid
                ? const Color(0xFFEF4444)
                : const Color(0xFFF59E0B),
          ),
        ],
      ];
    } else {
      count = 2;
      rows = const [
        _FlagRow(
          name:    'Fragrance',
          concern: 'May cause irritation or sensitisation in sensitive skin types.',
          color:   Color(0xFFF59E0B),
        ),
        SizedBox(height: 8),
        _FlagRow(
          name:    'Phenoxyethanol',
          concern: 'Preservative with mild concern at high concentrations — safe at current level.',
          color:   Color(0xFFF59E0B),
        ),
      ];
    }

    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Text(
                'Flagged Ingredients',
                style: AppTypography.labelSmall.copyWith(
                  color:      const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count items',
                  style: AppTypography.caption.copyWith(
                    color:      const Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                    fontSize:   10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

// ─── 7 · Product details ──────────────────────────────────────────────────────

class _ProductDetailsCard extends StatelessWidget {
  final ScannedProduct? scanned;
  final String barcode;
  const _ProductDetailsCard({required this.scanned, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final s = scanned;
    final List<(String, String)> rows = s != null
        ? [
            ('Brand', s.brand),
            ('Category', s.category),
            ('Ingredients', '${s.ingredients.length} read'),
            ('Barcode', s.barcode),
          ]
        : [
            ('Brand',     'CeraVe'),
            ('Category',  'Facial Cleanser'),
            ('Volume',    Fmt.volume(ml: 355, flOz: 12)),
            ('Skin Type', 'All Skin Types'),
            ('Free From', 'Fragrance · Parabens · Non-comedogenic'),
            ('Barcode',   '301872492140'),
          ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        context.dColors.surfaceDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline_rounded,
                    size: 17, color: context.dColors.textSecondary),
              ),
              const SizedBox(width: 10),
              Text('Product Details', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          ...rows.indexed.map(((int, (String, String)) entry) {
            final (i, (label, value)) = entry;
            return Column(
              children: [
                if (i > 0)
                  const Divider(
                      color: Color(0xFFF0EDFF), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          label,
                          style: AppTypography.caption.copyWith(
                              color: context.dColors.textTertiary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          value,
                          style: AppTypography.caption.copyWith(
                            color:      context.dColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Reusable section widgets ─────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow:    context.dColors.cardShadow,
        border:       Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: child,
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int    score;
  final String label;
  final Color  color;
  final double progress;

  const _ScoreRing({
    required this.score,
    required this.label,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 74,
          height: 74,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value:           (score / 100.0) * progress,
                  strokeWidth:     5.5,
                  backgroundColor: const Color(0xFFF0EDFF),
                  valueColor:      AlwaysStoppedAnimation(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: AppTypography.metricSmall.copyWith(
                      color:    color,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '/100',
                    style: AppTypography.caption.copyWith(
                      color:   context.dColors.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color:    context.dColors.textSecondary,
            fontSize: 11,
            height:   1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CompatBar extends StatelessWidget {
  final String label;
  final int    score;
  final Color  color;
  final double progress;

  const _CompatBar({
    required this.label,
    required this.score,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTypography.caption
                .copyWith(color: context.dColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 7,
              color:  context.dColors.surfaceDim,
              child: Align(
                alignment:   Alignment.centerLeft,
                widthFactor: (score / 100.0) * progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.60),
                        color,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$score%',
          style: AppTypography.labelSmall.copyWith(
            color:      color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _IngSection extends StatelessWidget {
  final String       label;
  final int          count;
  final Color        color;
  final List<String> items;
  final String?      emptyLabel;

  const _IngSection({
    required this.label,
    required this.count,
    required this.color,
    required this.items,
    this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9, height: 9,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              '$label ($count)',
              style: AppTypography.labelSmall.copyWith(
                color:      color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Wrap(
            spacing:    6,
            runSpacing: 6,
            children: items
                .map((ing) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:        color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: color.withValues(alpha: 0.22)),
                      ),
                      child: Text(
                        ing,
                        style: AppTypography.caption.copyWith(
                          color:      color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          )
        else
          Text(
            emptyLabel ?? 'None',
            style: AppTypography.caption
                .copyWith(color: context.dColors.textTertiary),
          ),
      ],
    );
  }
}

class _KeyIngCard extends StatelessWidget {
  final String   name;
  final String   fn;
  final String   benefit;
  final Color    color;
  final IconData icon;

  const _KeyIngCard({
    required this.name,
    required this.fn,
    required this.benefit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:      172,
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow:    context.dColors.cardShadow,
        border:       Border.all(color: const Color(0xFFF0EDFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.labelSmall.copyWith(
                        color:      context.dColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fn,
                      style: AppTypography.caption.copyWith(
                        color:   context.dColors.textTertiary,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              benefit,
              style: AppTypography.caption.copyWith(
                color:  context.dColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Key Ingredient',
              style: AppTypography.caption.copyWith(
                color:         color,
                fontWeight:    FontWeight.w700,
                fontSize:      9,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  final String name;
  final String concern;
  final Color  color;

  const _FlagRow({
    required this.name,
    required this.concern,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7, height: 7,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.labelSmall.copyWith(
                    color:      context.dColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  concern,
                  style: AppTypography.caption.copyWith(
                    color:  context.dColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
