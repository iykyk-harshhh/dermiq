import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final Set<String> _readIds;

  static const _all = [
    // ── Today (start unread) ──────────────────────────────────────────────
    _Notif(
      id: 'n1',
      title: 'AM Routine Reminder',
      body: 'Your 3-step morning routine is waiting. Keep your 8-day streak alive!',
      time: '8:00 AM',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFF7C5CFF),
      category: 'Routine',
      group: _Group.today,
      actionLabel: 'Start Routine',
      actionRoute: '/routine',
    ),
    _Notif(
      id: 'n2',
      title: 'Skin Score Updated',
      body: 'Your skin score improved from 79 → 82 this week. Great progress!',
      time: '9:15 AM',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF22C55E),
      category: 'Score',
      group: _Group.today,
      actionLabel: 'View Analysis',
      actionRoute: '/analysis',
    ),
    // ── Yesterday (start read) ────────────────────────────────────────────
    _Notif(
      id: 'n3',
      title: 'Product Expiry Alert',
      body: 'CeraVe Hydrating Cleanser expires in 12 days. Consider restocking soon.',
      time: '11:30 AM',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFF59E0B),
      category: 'Alert',
      group: _Group.yesterday,
      actionLabel: 'View Product',
      actionRoute: '/shelf',
    ),
    _Notif(
      id: 'n4',
      title: 'PM Routine Reminder',
      body: 'You completed 2 of 3 evening steps. Don\'t skip your night moisturiser!',
      time: '9:00 PM',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFF7C5CFF),
      category: 'Routine',
      group: _Group.yesterday,
      actionLabel: 'Open Routine',
      actionRoute: '/routine',
    ),
    _Notif(
      id: 'n5',
      title: 'New Matches Found',
      body: '3 products matched your Combination skin profile this week.',
      time: '3:00 PM',
      icon: Icons.star_rounded,
      color: Color(0xFF8B5CF6),
      category: 'Discovery',
      group: _Group.yesterday,
      actionLabel: 'See Matches',
      actionRoute: '/shelf',
    ),
    // ── Earlier (start read) ──────────────────────────────────────────────
    _Notif(
      id: 'n6',
      title: '7-Day Streak!',
      body: 'You\'ve completed your skincare routine 7 days in a row. Keep it up!',
      time: 'Mon',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEF4444),
      category: 'Achievement',
      group: _Group.earlier,
      actionLabel: 'View Rewards',
      actionRoute: '/profile/gifts',
    ),
    _Notif(
      id: 'n7',
      title: 'DermIQ Insight',
      body: 'Niacinamide and your Vitamin C serum can be layered safely at different pH levels.',
      time: 'Sun',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF0EA5E9),
      category: 'Tip',
      group: _Group.earlier,
      actionLabel: 'Learn More',
      actionRoute: '/ingredients',
    ),
    _Notif(
      id: 'n8',
      title: 'Fragrance Detected',
      body: 'Fragrance is listed in 2 recently scanned products — may trigger your sensitivity.',
      time: 'Sat',
      icon: Icons.science_rounded,
      color: Color(0xFFF43F5E),
      category: 'Alert',
      group: _Group.earlier,
      actionLabel: 'Check Products',
      actionRoute: '/shelf',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Only today's notifications start unread
    _readIds = _all
        .where((n) => n.group != _Group.today)
        .map((n) => n.id)
        .toSet();
  }

  bool _isRead(String id) => _readIds.contains(id);
  int get _unreadCount => _all.where((n) => !_isRead(n.id)).length;

  void _markRead(String id) {
    if (!_isRead(id)) setState(() => _readIds.add(id));
  }

  void _markAllRead() {
    setState(() => _readIds.addAll(_all.map((n) => n.id)));
  }

  /// Tapping a notification marks it read and opens its destination.
  void _open(_Notif n) {
    _markRead(n.id);
    if (n.actionRoute != null) context.push(n.actionRoute!);
  }

  List<_Notif> _group(_Group g) => _all.where((n) => n.group == g).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: context.dColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            toolbarHeight: 60,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: context.dColors.cardShadow,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: context.dColors.textPrimary,
                ),
              ),
            ),
            title: Text('Notifications', style: AppTypography.h4),
            centerTitle: true,
            actions: [
              if (_unreadCount > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Mark all read',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unread count banner
                  _UnreadBanner(
                    count: _unreadCount,
                    onMarkAll: _markAllRead,
                  ),

                  if (_group(_Group.today).isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Today',
                      count: _group(_Group.today).length,
                    ),
                    const SizedBox(height: 10),
                    ..._group(_Group.today).asMap().entries.map((e) =>
                        _NotifCard(
                          notif: e.value,
                          isRead: _isRead(e.value.id),
                          onTap: () => _open(e.value),
                          onActionTap: e.value.actionRoute != null
                              ? () => context.push(e.value.actionRoute!)
                              : null,
                        )
                            .animate()
                            .fadeIn(
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key),
                            )
                            .slideY(
                              begin: 0.08,
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key),
                              curve: Curves.easeOutCubic,
                            )),
                    const SizedBox(height: 16),
                  ],

                  if (_group(_Group.yesterday).isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Yesterday',
                      count: _group(_Group.yesterday).length,
                    ),
                    const SizedBox(height: 10),
                    ..._group(_Group.yesterday).asMap().entries.map((e) =>
                        _NotifCard(
                          notif: e.value,
                          isRead: _isRead(e.value.id),
                          onTap: () => _open(e.value),
                          onActionTap: e.value.actionRoute != null
                              ? () => context.push(e.value.actionRoute!)
                              : null,
                        )
                            .animate()
                            .fadeIn(
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key + 100),
                            )
                            .slideY(
                              begin: 0.08,
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key + 100),
                              curve: Curves.easeOutCubic,
                            )),
                    const SizedBox(height: 16),
                  ],

                  if (_group(_Group.earlier).isNotEmpty) ...[
                    _SectionHeader(
                      label: 'Earlier',
                      count: _group(_Group.earlier).length,
                    ),
                    const SizedBox(height: 10),
                    ..._group(_Group.earlier).asMap().entries.map((e) =>
                        _NotifCard(
                          notif: e.value,
                          isRead: _isRead(e.value.id),
                          onTap: () => _open(e.value),
                          onActionTap: e.value.actionRoute != null
                              ? () => context.push(e.value.actionRoute!)
                              : null,
                        )
                            .animate()
                            .fadeIn(
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key + 200),
                            )
                            .slideY(
                              begin: 0.08,
                              duration: 360.ms,
                              delay: Duration(milliseconds: 50 * e.key + 200),
                              curve: Curves.easeOutCubic,
                            )),
                  ],

                  const SizedBox(height: 80),
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
// Data
// ─────────────────────────────────────────────────────────────────────────────

enum _Group { today, yesterday, earlier }

class _Notif {
  final String id;
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final String category;
  final _Group group;
  final String? actionLabel;
  final String? actionRoute;

  const _Notif({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.category,
    required this.group,
    this.actionLabel,
    this.actionRoute,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Unread count banner
// ─────────────────────────────────────────────────────────────────────────────

class _UnreadBanner extends StatelessWidget {
  final int count;
  final VoidCallback onMarkAll;

  const _UnreadBanner({required this.count, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Text(
                'All caught up — no unread notifications',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count unread',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;

  const _SectionHeader({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: context.dColors.textTertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: AppTypography.overline.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(
            color: Color(0xFFEDE9FE),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification card
// ─────────────────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final bool isRead;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  const _NotifCard({
    required this.notif,
    required this.isRead,
    required this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: context.dColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left accent stripe — only for unread
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: isRead ? 0 : 4,
                  color: notif.color,
                ),

                // Main content
                Expanded(
                  child: Container(
                    color: isRead
                        ? Colors.white
                        : notif.color.withValues(alpha: 0.035),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: notif.color.withValues(
                                  alpha: isRead ? 0.09 : 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              notif.icon,
                              color: notif.color,
                              size: 21,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title + time row
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                          color: context.dColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notif.time,
                                      style: AppTypography.caption.copyWith(
                                        color: context.dColors.textTertiary,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                // Category badge
                                _CategoryBadge(
                                  label: notif.category,
                                  color: notif.color,
                                  isRead: isRead,
                                ),

                                const SizedBox(height: 6),

                                // Body
                                Text(
                                  notif.body,
                                  style: AppTypography.caption.copyWith(
                                    color: context.dColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),

                                // Action chip
                                if (notif.actionLabel != null) ...[
                                  const SizedBox(height: 9),
                                  _ActionChip(
                                    label: notif.actionLabel!,
                                    color: notif.color,
                                    onTap: onActionTap,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
// Category badge
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isRead;

  const _CategoryBadge({
    required this.label,
    required this.color,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isRead ? 0.07 : 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: isRead ? 0.16 : 0.24),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action chip
// ─────────────────────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}
