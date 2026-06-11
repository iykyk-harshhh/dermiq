import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: context.dColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            pinned: false,
            toolbarHeight: 60,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.dColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: context.dColors.cardShadow,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: context.dColors.textPrimary,
                ),
              ),
            ),
            title: Text('Scan Product', style: AppTypography.h4),
            centerTitle: true,
          ),

          // ── Content ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPaddingH,
              4,
              AppConstants.screenPaddingH,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                const _ScanHeader()
                    .animate()
                    .fadeIn(duration: 360.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: 22),

                // Smart Scan Card — driven by animation
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseCtrl, _scanCtrl]),
                  builder: (_, _) => _SmartScanCard(
                    pulseValue: _pulseCtrl.value,
                    scanValue: _scanCtrl.value,
                    onTap: () => context.push('/scan/ingredient'),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 440.ms, delay: 60.ms)
                    .slideY(begin: 0.08, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // OR divider
                const _OrDivider()
                    .animate()
                    .fadeIn(duration: 320.ms, delay: 120.ms),

                const SizedBox(height: 16),

                // Manual Search Card
                _ManualSearchCard(
                  onSearchTap: () => context.push('/scan/manual'),
                  onRecentTap: (_) => context.push('/scan/results'),
                )
                    .animate()
                    .fadeIn(duration: 420.ms, delay: 180.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),

                const SizedBox(height: 28),

                // Quick Tips
                const _QuickTipsSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 260.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _ScanHeader extends StatelessWidget {
  const _ScanHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Product',
          style: AppTypography.h3.copyWith(color: context.dColors.textPrimary),
        ),
        const SizedBox(height: 5),
        Text(
          'Scan or search to get instant safety analysis and ingredient ratings.',
          style: AppTypography.bodyMedium
              .copyWith(color: context.dColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Smart Scan Card
// ─────────────────────────────────────────────────────────────────────────────

class _SmartScanCard extends StatelessWidget {
  final double pulseValue;
  final double scanValue;
  final VoidCallback onTap;

  const _SmartScanCard({
    required this.pulseValue,
    required this.scanValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          boxShadow: AppColors.elevatedShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF3B2D9F),
                  Color(0xFF5E3FFF),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Background blobs
                Positioned(
                  right: -24,
                  top: -24,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  left: -16,
                  bottom: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Animated scan icon
                          _ScanIconWidget(
                            pulseValue: pulseValue,
                            scanValue: scanValue,
                          ),

                          const SizedBox(width: 20),

                          // Title + description + chips
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Scan',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Scan barcode, ingredients, or product packaging',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.68),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: const [
                                    _CapabilityChip(
                                        'Barcode', Icons.qr_code_2_rounded),
                                    _CapabilityChip('Ingredients',
                                        Icons.list_alt_rounded),
                                    _CapabilityChip('Packaging',
                                        Icons.inventory_2_rounded),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // CTA row
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Open Smart Scanner',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 14, color: Colors.white),
                          ],
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan icon — pulsing rings + animated scan line
// ─────────────────────────────────────────────────────────────────────────────

class _ScanIconWidget extends StatelessWidget {
  final double pulseValue;
  final double scanValue;

  const _ScanIconWidget({
    required this.pulseValue,
    required this.scanValue,
  });

  @override
  Widget build(BuildContext context) {
    final outerGlow = 0.06 + 0.12 * pulseValue;
    final outerScale = 1.0 + 0.06 * pulseValue;

    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          Transform.scale(
            scale: outerScale,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: outerGlow),
                  width: 1.0,
                ),
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: 0.12 + 0.10 * pulseValue),
                width: 1.5,
              ),
            ),
          ),
          // Inner gradient square + scan line + icon
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                children: [
                  // Gradient bg
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                  // Scan line — sweeps downward
                  Positioned(
                    top: (44 * scanValue).clamp(2.0, 42.0),
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.80),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lavender.withValues(alpha: 0.60),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Camera icon
                  Center(
                    child: Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Capability chip — glass style
// ─────────────────────────────────────────────────────────────────────────────

class _CapabilityChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CapabilityChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.80)),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OR divider
// ─────────────────────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8DEFF), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: AppTypography.caption.copyWith(
              color: context.dColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8DEFF), thickness: 1)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manual Search Card
// ─────────────────────────────────────────────────────────────────────────────

class _ManualSearchCard extends StatelessWidget {
  final VoidCallback onSearchTap;
  final ValueChanged<String> onRecentTap;

  const _ManualSearchCard({
    required this.onSearchTap,
    required this.onRecentTap,
  });

  static const _recents = [
    'CeraVe Cleanser',
    'Niacinamide 10%',
    'SPF 50 Sunscreen',
    'Retinol Cream',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: const Color(0xFFF0EDFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Manual Search',
                style: AppTypography.labelMedium.copyWith(
                  color: context.dColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tappable search field
          GestureDetector(
            onTap: onSearchTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
              decoration: BoxDecoration(
                color: context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                border: Border.all(
                  color: context.dColors.borderLight,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search product or ingredient...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.dColors.textTertiary,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent searches label
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 14,
                color: context.dColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                'Recent searches',
                style: AppTypography.caption.copyWith(
                  color: context.dColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Recent chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_recents.length, (i) {
              return _RecentChip(
                label: _recents[i],
                onTap: () => onRecentTap(_recents[i]),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 50 * i + 220))
                  .scale(
                    begin: const Offset(0.90, 0.90),
                    duration: 300.ms,
                    delay: Duration(milliseconds: 50 * i + 220),
                    curve: Curves.easeOutBack,
                  );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent search chip
// ─────────────────────────────────────────────────────────────────────────────

class _RecentChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RecentChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.dColors.surfaceDim,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8DEFF), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 12,
              color: context.dColors.textTertiary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: context.dColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Tips
// ─────────────────────────────────────────────────────────────────────────────

class _QuickTipsSection extends StatelessWidget {
  const _QuickTipsSection();

  static const _tips = [
    _Tip(
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFF59E0B),
      text: 'Good lighting dramatically improves scan accuracy.',
    ),
    _Tip(
      icon: Icons.zoom_in_rounded,
      color: Color(0xFF0EA5E9),
      text: 'Zoom in on the ingredient list for best text recognition.',
    ),
    _Tip(
      icon: Icons.auto_awesome_rounded,
      color: AppColors.primary,
      text: 'DermIQ analyses 1,000+ ingredients in real time.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Tips', style: AppTypography.h4),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.dColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            boxShadow: context.dColors.cardShadow,
            border: Border.all(color: const Color(0xFFF0EDFF), width: 1),
          ),
          child: Column(
            children: List.generate(_tips.length, (i) {
              return Column(
                children: [
                  _TipRow(tip: _tips[i])
                      .animate()
                      .fadeIn(
                        duration: 340.ms,
                        delay: Duration(milliseconds: 60 * i + 280),
                      )
                      .slideX(
                        begin: 0.04,
                        duration: 340.ms,
                        delay: Duration(milliseconds: 60 * i + 280),
                        curve: Curves.easeOutCubic,
                      ),
                  if (i < _tips.length - 1)
                    const Divider(
                      color: Color(0xFFF5F3FF),
                      height: 1,
                      indent: 52,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _Tip {
  final IconData icon;
  final Color color;
  final String text;

  const _Tip({required this.icon, required this.color, required this.text});
}

class _TipRow extends StatelessWidget {
  final _Tip tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tip.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(tip.icon, size: 17, color: tip.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip.text,
              style: AppTypography.caption.copyWith(
                color: context.dColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
