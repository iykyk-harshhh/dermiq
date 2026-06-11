import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';
  int? _openFaq;

  static const _faqs = [
    (
      q: 'How does the skin score work?',
      a: 'Your skin score blends your scan analysis, routine consistency, and product compatibility into a single 0–100 number. It updates whenever you complete a scan or log a routine.',
    ),
    (
      q: 'Is my data private?',
      a: 'Yes. Your photos and health data are encrypted at rest and in transit, and are never sold. You can export or delete everything anytime from Privacy & Data.',
    ),
    (
      q: 'How do I scan a product?',
      a: 'Tap the centre Scan button in the bottom bar, point your camera at the ingredient list, and DermIQ will analyse it for matches and conflicts with your profile.',
    ),
    (
      q: 'Can I edit my routine?',
      a: 'Absolutely. Open Routine → Builder to add, remove or reorder steps for your AM and PM routines. Changes save instantly.',
    ),
    (
      q: 'How do I book a specialist?',
      a: 'Go to Find a Specialist, pick a doctor, choose a consultation type, date and time, then confirm. You\'ll find it under My Appointments.',
    ),
    (
      q: 'Why do products show expiry warnings?',
      a: 'When you add a product to your Shelf with an expiry date, DermIQ tracks it and flags items expiring within 30 days so nothing goes to waste.',
    ),
  ];

  List<({String q, String a})> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _faqs;
    return _faqs.where((f) =>
        f.q.toLowerCase().contains(q) || f.a.toLowerCase().contains(q)).toList();
  }

  void _snack(String msg) => AppSnackbar.show(context, msg);

  @override
  Widget build(BuildContext context) {
    final faqs = _filtered;
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Help & Support'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Hero ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientHeroDark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.heroShadow,
            ),
            child: Column(
              children: [
                const Text('👋', style: TextStyle(fontSize: 34)),
                const SizedBox(height: 8),
                Text('How can we help?',
                    style: AppTypography.h4.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('Search our FAQs or reach out to the team',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04),

          const SizedBox(height: 16),

          // ── Search ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: context.dColors.textTertiary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search for help',
                      hintStyle: AppTypography.bodyMedium
                          .copyWith(color: context.dColors.textTertiary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (v) => setState(() {
                      _query = v;
                      _openFaq = null;
                    }),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

          const SizedBox(height: 16),

          // ── Contact options ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _ContactCard(
                icon: Icons.chat_bubble_rounded,
                color: AppColors.primary,
                label: 'Live Chat',
                sub: 'Avg. 2 min',
                onTap: () => _snack('Opening live chat…'),
              )),
              const SizedBox(width: 10),
              Expanded(child: _ContactCard(
                icon: Icons.mail_rounded,
                color: const Color(0xFFEC4899),
                label: 'Email Us',
                sub: 'help@dermiq.app',
                onTap: () => _snack('Composing email to help@dermiq.app…'),
              )),
              const SizedBox(width: 10),
              Expanded(child: _ContactCard(
                icon: Icons.call_rounded,
                color: AppColors.success,
                label: 'Call',
                sub: 'Mon–Fri',
                onTap: () => _snack('Calling support…'),
              )),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

          const SizedBox(height: 22),

          // ── FAQ ──────────────────────────────────────────────────────────
          Row(
            children: [
              Text('Frequently Asked', style: AppTypography.labelLarge),
              const Spacer(),
              if (_query.isNotEmpty)
                Text('${faqs.length} result${faqs.length == 1 ? '' : 's'}',
                    style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
            ],
          ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

          const SizedBox(height: 12),

          if (faqs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: context.dColors.cardShadow,
              ),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 44, color: context.dColors.textTertiary),
                  const SizedBox(height: 10),
                  Text('No results for "$_query"',
                      style: AppTypography.bodySmall.copyWith(color: context.dColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text('Try a different term or contact us above',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
                ],
              ),
            )
          else
            ...List.generate(faqs.length, (i) {
              final f = faqs[i];
              return _FaqTile(
                question: f.q,
                answer: f.a,
                open: _openFaq == i,
                onTap: () => setState(() => _openFaq = _openFaq == i ? null : i),
              ).animate().fadeIn(delay: (180 + i * 50).ms, duration: 280.ms);
            }),

          const SizedBox(height: 20),

          // ── More links ───────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Column(
              children: [
                _LinkRow(
                  icon: Icons.menu_book_rounded,
                  label: 'User Guide',
                  onTap: () => _snack('Opening user guide…'),
                ),
                _LinkRow(
                  icon: Icons.bug_report_outlined,
                  label: 'Report a Problem',
                  onTap: () => _snack('Opening problem report…'),
                ),
                _LinkRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About DermIQ',
                  onTap: () => context.push('/settings/about'),
                  last: true,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 480.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ── _ContactCard ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, sub;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTypography.labelMedium.copyWith(fontSize: 12),
                textAlign: TextAlign.center),
            Text(sub,
                style: AppTypography.caption.copyWith(
                    color: context.dColors.textTertiary, fontSize: 10),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── _FaqTile ──────────────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
  final String question, answer;
  final bool open;
  final VoidCallback onTap;
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(
            color: open ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(question,
                        style: AppTypography.labelMedium.copyWith(
                            color: open ? AppColors.primary : context.dColors.textPrimary)),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: open ? AppColors.primary : context.dColors.textTertiary, size: 22),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(answer,
                    style: AppTypography.bodySmall.copyWith(height: 1.55)),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ── _LinkRow ──────────────────────────────────────────────────────────────────

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: AppTypography.labelMedium)),
                Icon(Icons.chevron_right_rounded,
                    color: context.dColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.only(left: 66, right: 16),
            child: Divider(color: context.dColors.borderLight, height: 1),
          ),
      ],
    );
  }
}
