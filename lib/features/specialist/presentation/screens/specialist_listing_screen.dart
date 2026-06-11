import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/specialist_models.dart';

class SpecialistListingScreen extends StatefulWidget {
  final String? initialType;
  const SpecialistListingScreen({super.key, this.initialType});

  @override
  State<SpecialistListingScreen> createState() => _SpecialistListingScreenState();
}

class _SpecialistListingScreenState extends State<SpecialistListingScreen> {
  // Multi-select filter chips across two dimensions: specialist type and
  // consultation mode. Empty selection = show everyone.
  final Set<String> _selected = {};
  String _query = '';
  bool _showSearch = false;

  static const _typeChips = ['Dermatologist', 'Trichologist', 'Cosmetologist'];
  static const _modeChips = ['Online', 'In-Person'];
  static const _chips = [..._typeChips, ..._modeChips];

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null && _typeChips.contains(widget.initialType)) {
      _selected.add(widget.initialType!);
    }
  }

  List<Specialist> get _filtered {
    final types = _selected.where(_typeChips.contains).toSet();
    final modes = _selected.where(_modeChips.contains).toSet();
    return specialistMocks.where((s) {
      final matchesType = types.isEmpty || types.contains(s.type);
      final matchesMode = modes.isEmpty ||
          (modes.contains('Online') && s.offersOnline) ||
          (modes.contains('In-Person') && s.offersInPerson);
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.type.toLowerCase().contains(q) ||
          s.specialties.any((sp) => sp.toLowerCase().contains(q));
      return matchesType && matchesMode && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _HeaderBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  Text('Find a Specialist', style: AppTypography.h4),
                  const Spacer(),
                  _HeaderBtn(
                    icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
                    onTap: () => setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) _query = '';
                    }),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
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
                          autofocus: true,
                          style: AppTypography.bodyMedium
                              .copyWith(color: context.dColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search name, type or concern',
                            hintStyle: AppTypography.bodyMedium
                                .copyWith(color: context.dColors.textTertiary),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms),

            // ── My appointments banner ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: GestureDetector(
                onTap: () => context.push('/appointments'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: context.dColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_note_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Appointments',
                                style: AppTypography.labelMedium
                                    .copyWith(color: Colors.white)),
                            Text(
                              '${myAppointmentsMock.where((a) => a.status == AppointmentStatus.upcoming).length} upcoming',
                              style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

            // ── Filter chips ───────────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final label = _chips[i];
                  final active = _selected.contains(label);
                  final isMode = _modeChips.contains(label);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (active) {
                        _selected.remove(label);
                      } else {
                        _selected.add(label);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : context.dColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active ? AppColors.primary : context.dColors.borderLight),
                        boxShadow: active ? AppColors.elevatedShadow : context.dColors.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMode) ...[
                            Icon(
                              label == 'Online'
                                  ? Icons.videocam_rounded
                                  : Icons.location_on_rounded,
                              size: 13,
                              color: active ? Colors.white : context.dColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(label,
                              style: AppTypography.labelSmall.copyWith(
                                color: active ? Colors.white : context.dColors.textSecondary,
                                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Results ────────────────────────────────────────────────────
            Expanded(
              child: list.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final s = list[i];
                        return _SpecCard(
                          specialist: s,
                          onTap: () => context.push('/specialist/${s.id}'),
                        ).animate()
                            .fadeIn(duration: 350.ms, delay: (i * 70).ms)
                            .slideY(begin: 0.08);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _HeaderBtn ────────────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: context.dColors.textPrimary),
        ),
      );
}

// ── _EmptyState ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: context.dColors.textTertiary),
          const SizedBox(height: 12),
          Text('No specialists found',
              style: AppTypography.labelLarge.copyWith(color: context.dColors.textTertiary)),
          const SizedBox(height: 6),
          Text('Try a different filter or search term',
              style: AppTypography.bodySmall.copyWith(color: context.dColors.textTertiary)),
        ],
      ),
    );
  }
}

// ── _SpecCard ─────────────────────────────────────────────────────────────────

class _SpecCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;
  const _SpecCard({required this.specialist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = specialist;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.dColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: context.dColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [s.color, s.color.withValues(alpha: 0.7)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(s.initials,
                        style: AppTypography.h4.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: AppTypography.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(s.type,
                          style: AppTypography.caption.copyWith(color: s.color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(s.hospital,
                          style: AppTypography.caption.copyWith(
                              color: context.dColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('Book',
                          style: AppTypography.buttonSmall.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('\$${s.fee.toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                            color: context.dColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 13, color: context.dColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(s.address,
                      style: AppTypography.caption.copyWith(
                          color: context.dColors.textTertiary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Icon(Icons.near_me_rounded,
                    size: 12, color: context.dColors.textTertiary),
                const SizedBox(width: 3),
                Text('${s.distanceKm} km',
                    style: AppTypography.caption.copyWith(
                        color: context.dColors.textTertiary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFD4A017), size: 14),
                const SizedBox(width: 4),
                Text('${s.rating} · ${s.reviews} reviews',
                    style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.specialties.take(3).join(' · '),
                      style: AppTypography.caption.copyWith(
                          color: context.dColors.textTertiary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
