import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/specialist_models.dart';
import '../../providers/appointment_provider.dart';

class MyAppointmentsScreen extends ConsumerStatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  ConsumerState<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends ConsumerState<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _setCancelled(String id) =>
      ref.read(appointmentProvider.notifier).cancel(id);

  /// Open full details; if the user cancels from there, reflect it here.
  Future<void> _open(Appointment a) async {
    final r = await context.push(AppRoutes.appointmentDetail(a.id), extra: a);
    if (r == 'cancelled') _setCancelled(a.id);
  }

  void _cancel(Appointment appt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Appointment?', style: AppTypography.h4),
        content: Text(
          'Cancel your ${appt.consultType.toLowerCase()} with ${appt.specialist.name} on ${appt.dateLabel}?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep',
                style: AppTypography.buttonSmall.copyWith(color: context.dColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setCancelled(appt.id);
            },
            child: Text('Cancel It',
                style: AppTypography.buttonSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(appointmentProvider);
    final upcoming = all.where((a) => a.status == AppointmentStatus.upcoming).toList();
    final completed = all.where((a) => a.status == AppointmentStatus.completed).toList();
    final cancelled = all.where((a) => a.status == AppointmentStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/specialist'),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('My Appointments', style: AppTypography.h4),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: context.dColors.surface,
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: context.dColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelStyle: AppTypography.labelMedium,
              unselectedLabelStyle: AppTypography.labelMedium,
              tabs: [
                Tab(text: 'Upcoming (${upcoming.length})'),
                Tab(text: 'Past (${completed.length})'),
                Tab(text: 'Cancelled (${cancelled.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _AppointmentList(
            appointments: upcoming,
            emptyIcon: Icons.event_available_rounded,
            emptyText: 'No upcoming appointments',
            emptySub: 'Book a specialist to see it here',
            onCancel: _cancel,
            onBookAgain: null,
            onOpen: _open,
            onReschedule: (a) => context.push(AppRoutes.specialistDetail(a.specialistId)),
          ),
          _AppointmentList(
            appointments: completed,
            emptyIcon: Icons.history_rounded,
            emptyText: 'No past appointments',
            emptySub: 'Your completed visits will appear here',
            onCancel: null,
            onBookAgain: (a) => context.push('/specialist/${a.specialistId}'),
            onOpen: _open,
            onReschedule: (a) => context.push(AppRoutes.specialistDetail(a.specialistId)),
          ),
          _AppointmentList(
            appointments: cancelled,
            emptyIcon: Icons.event_busy_rounded,
            emptyText: 'No cancelled appointments',
            emptySub: 'Nothing here — great commitment!',
            onCancel: null,
            onBookAgain: (a) => context.push('/specialist/${a.specialistId}'),
            onOpen: _open,
            onReschedule: (a) => context.push(AppRoutes.specialistDetail(a.specialistId)),
          ),
        ],
      ),
      floatingActionButton: _tab.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/specialist'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text('Book New',
                  style: AppTypography.buttonSmall.copyWith(color: Colors.white)),
            )
          : null,
    );
  }
}

// ── _AppointmentList ──────────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final IconData emptyIcon;
  final String emptyText, emptySub;
  final void Function(Appointment)? onCancel;
  final void Function(Appointment)? onBookAgain;
  final void Function(Appointment) onOpen;
  final void Function(Appointment) onReschedule;

  const _AppointmentList({
    required this.appointments,
    required this.emptyIcon,
    required this.emptyText,
    required this.emptySub,
    required this.onCancel,
    required this.onBookAgain,
    required this.onOpen,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyText,
        subtitle: emptySub,
        actionLabel: 'Find a Specialist',
        onAction: () => context.push('/specialist'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: appointments.length,
      itemBuilder: (_, i) {
        final a = appointments[i];
        return _AppointmentCard(
          appointment: a,
          onCancel: onCancel == null ? null : () => onCancel!(a),
          onBookAgain: onBookAgain == null ? null : () => onBookAgain!(a),
          onReschedule: () => onReschedule(a),
          onTap: () => onOpen(a),
        ).animate().fadeIn(duration: 300.ms, delay: (i * 70).ms).slideY(begin: 0.06);
      },
    );
  }
}

// ── _AppointmentCard ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onBookAgain;
  final VoidCallback onReschedule;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onCancel,
    required this.onBookAgain,
    required this.onReschedule,
    required this.onTap,
  });

  ({Color color, String label, IconData icon}) get _statusMeta {
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        return (color: AppColors.success, label: 'Upcoming', icon: Icons.schedule_rounded);
      case AppointmentStatus.completed:
        return (color: AppColors.primary, label: 'Completed', icon: Icons.check_circle_rounded);
      case AppointmentStatus.cancelled:
        return (color: AppColors.error, label: 'Cancelled', icon: Icons.cancel_rounded);
      case AppointmentStatus.missed:
        return (color: AppColors.warning, label: 'Missed', icon: Icons.event_busy_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = appointment.specialist;
    final meta = _statusMeta;
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Opacity(
                    opacity: isCancelled ? 0.5 : 1,
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [s.color, s.color.withValues(alpha: 0.7)]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text(s.initials,
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            style: AppTypography.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(s.type,
                            style: AppTypography.caption.copyWith(color: s.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(meta.icon, size: 12, color: meta.color),
                        const SizedBox(width: 4),
                        Text(meta.label,
                            style: AppTypography.caption.copyWith(
                                color: meta.color, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(color: context.dColors.borderLight, height: 1),

          // Detail row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _MetaChip(icon: Icons.event_rounded, text: appointment.dateLabel),
                const SizedBox(width: 10),
                _MetaChip(icon: Icons.access_time_rounded, text: appointment.time),
                const SizedBox(width: 10),
                _MetaChip(
                    icon: consultIcon(appointment.consultType),
                    text: appointment.consultType),
              ],
            ),
          ),

          // Actions
          if (onCancel != null || onBookAgain != null) ...[
            Divider(color: context.dColors.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (appointment.status == AppointmentStatus.upcoming) ...[
                    Expanded(
                      child: _ActionBtn(
                        label: 'Reschedule',
                        icon: Icons.edit_calendar_rounded,
                        color: AppColors.primary,
                        filled: false,
                        onTap: onReschedule,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Cancel',
                        icon: Icons.close_rounded,
                        color: AppColors.error,
                        filled: false,
                        onTap: onCancel!,
                      ),
                    ),
                  ] else if (onBookAgain != null) ...[
                    Expanded(
                      child: _ActionBtn(
                        label: 'Book Again',
                        icon: Icons.refresh_rounded,
                        color: AppColors.primary,
                        filled: true,
                        onTap: onBookAgain!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── _MetaChip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.dColors.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: AppTypography.caption.copyWith(
                    color: context.dColors.textSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── _ActionBtn ────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13),
          border: filled ? null : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonSmall.copyWith(
                      color: filled ? Colors.white : color)),
            ),
          ],
        ),
      ),
    );
  }
}
