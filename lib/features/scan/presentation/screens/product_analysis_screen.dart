import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../shelf/data/shelf_models.dart';
import '../../../shelf/providers/shelf_provider.dart';

// The analyzed product (currently the mock OCR result the screen displays).
const _kName = 'CeraVe Foaming Facial Cleanser';
const _kBrand = 'CeraVe';
const _kCategory = 'Cleanser';
const _kSafetyScore = 92;
const _kSkinMatch = 88;
const _kHairMatch = 75;

// ─── Screen ──────────────────────────────────────────────────────────────────

class ProductAnalysisScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductAnalysisScreen({super.key, required this.productId});

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

  /// Save Product → Add To Shelf (Scanner is a shelf source, per spec).
  void _addToShelf() {
    final now = DateTime.now();
    ref.read(shelfProvider.notifier).addProduct(ShelfProduct(
          id: 'scan_${widget.productId}_${now.millisecondsSinceEpoch}',
          name: _kName,
          brand: _kBrand,
          category: _kCategory,
          score: _kSafetyScore,
          color: AppColors.primary,
          purchaseDate: now,
          expiryDate: now.add(const Duration(days: 365)),
          notes: 'Added from scan analysis',
          skinMatch: _kSkinMatch,
          hairMatch: _kHairMatch,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_kName added to My Shelf',
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
              background:   _HeroBackground(),
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
                  ),
                ).animate()
                    .fadeIn(duration: 380.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 2 · AI Verdict
                const _AiVerdictBanner()
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 60.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 3 · Compatibility
                AnimatedBuilder(
                  animation: _enterAnim,
                  builder: (_, _) =>
                      _CompatibilityCard(progress: _enterAnim.value),
                )
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 100.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 4 · Ingredient Breakdown
                const _IngredientBreakdownCard()
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 140.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 5 · Key Ingredients
                const _KeyIngredientsSection()
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 180.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 6 · Flagged Ingredients
                const _FlaggedCard()
                    .animate()
                    .fadeIn(duration: 360.ms, delay: 220.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 14),

                // 7 · Product Details
                const _ProductDetailsCard()
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
  @override
  Widget build(BuildContext context) {
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
                    'CeraVe Foaming Facial Cleanser',
                    style: AppTypography.h4.copyWith(
                      color:     Colors.white,
                      fontSize:  17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'CeraVe  ·  Cleanser  ·  355 ml',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Safety score hero chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:        const Color(0xFF22C55E)
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border:       Border.all(
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded,
                            size: 14, color: Color(0xFF22C55E)),
                        const SizedBox(width: 7),
                        Text(
                          '92 Safety Score  ·  Safe for You',
                          style: AppTypography.caption.copyWith(
                            color:      const Color(0xFF22C55E),
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
  const _SafetyOverviewCard({required this.progress});

  @override
  Widget build(BuildContext context) {
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
                score:    92,
                label:    'Safety\nScore',
                color:    const Color(0xFF22C55E),
                progress: progress,
              ),
              _ScoreRing(
                score:    88,
                label:    'Skin\nMatch',
                color:    AppColors.primary,
                progress: progress,
              ),
              _ScoreRing(
                score:    75,
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
              color:        const Color(0xFF22C55E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: Color(0xFF22C55E)),
                const SizedBox(width: 8),
                Text(
                  'Safe for your skin and hair profile',
                  style: AppTypography.labelSmall.copyWith(
                    color:      const Color(0xFF22C55E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const _RecommendationChip(score: _kSafetyScore),
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
  const _AiVerdictBanner();

  @override
  Widget build(BuildContext context) {
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
                  'CeraVe Foaming Cleanser is a strong match for your combination skin profile. '
                  'Ceramides and hyaluronic acid address your hydration goals, while niacinamide '
                  'targets pore appearance. One caution ingredient detected — see below.',
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
  const _CompatibilityCard({required this.progress});

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
              const _CompatVerdictChip(scores: [_kSkinMatch, _kHairMatch, 96]),
            ],
          ),
          const SizedBox(height: 18),
          _CompatBar(
            label:    'Skin Match',
            score:    88,
            color:    AppColors.primary,
            progress: progress,
          ),
          const SizedBox(height: 13),
          _CompatBar(
            label:    'Hair Match',
            score:    75,
            color:    const Color(0xFFF59E0B),
            progress: progress,
          ),
          const SizedBox(height: 13),
          _CompatBar(
            label:    'Allergy Check',
            score:    96,
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
  const _IngredientBreakdownCard();

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
                '24 total',
                style: AppTypography.caption
                    .copyWith(color: context.dColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _IngSection(
            label: 'Safe',
            count: 21,
            color: const Color(0xFF22C55E),
            items: const [
              'Niacinamide', 'Ceramide NP', 'Hyaluronic Acid',
              'Glycerin', 'Panthenol', 'Ceramide AP', 'Cholesterol',
            ],
          ),
          const SizedBox(height: 14),
          _IngSection(
            label: 'Caution',
            count: 2,
            color: const Color(0xFFF59E0B),
            items: const ['Fragrance', 'Phenoxyethanol'],
          ),
          const SizedBox(height: 14),
          _IngSection(
            label: 'Avoid',
            count: 1,
            color: const Color(0xFFEF4444),
            items: const [],
            emptyLabel: 'None detected',
          ),
        ],
      ),
    );
  }
}

// ─── 5 · Key ingredients ──────────────────────────────────────────────────────

class _KeyIngredientsSection extends StatelessWidget {
  const _KeyIngredientsSection();

  @override
  Widget build(BuildContext context) {
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
            children: const [
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
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 6 · Flagged ingredients ──────────────────────────────────────────────────

class _FlaggedCard extends StatelessWidget {
  const _FlaggedCard();

  @override
  Widget build(BuildContext context) {
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
                  '2 items',
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
          _FlagRow(
            name:    'Fragrance',
            concern: 'May cause irritation or sensitisation in sensitive skin types.',
            color:   const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 8),
          _FlagRow(
            name:    'Phenoxyethanol',
            concern: 'Preservative with mild concern at high concentrations — safe at current level.',
            color:   const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

// ─── 7 · Product details ──────────────────────────────────────────────────────

class _ProductDetailsCard extends StatelessWidget {
  const _ProductDetailsCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Brand',     'CeraVe'),
      ('Category',  'Facial Cleanser'),
      ('Volume',    '355 ml / 12 fl oz'),
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
