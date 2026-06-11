import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _masterEnabled = true;

  final List<_Reminder> _reminders = [
    _Reminder('Morning Routine', const TimeOfDay(hour: 7, minute: 0),
        Icons.wb_sunny_rounded, const Color(0xFFF59E0B), true),
    _Reminder('Evening Routine', const TimeOfDay(hour: 21, minute: 30),
        Icons.nightlight_rounded, const Color(0xFF7C5CFF), true),
    _Reminder('Skin Check-In', const TimeOfDay(hour: 20, minute: 0),
        Icons.favorite_rounded, const Color(0xFF22C55E), false),
    _Reminder('Product Refill', const TimeOfDay(hour: 10, minute: 0),
        Icons.inventory_2_rounded, const Color(0xFFEC4899), false),
  ];

  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // every day
  static const _dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  Future<void> _editTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminders[index].time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      final r = _reminders[index];
      _reminders[index] = r.copyWith(time: picked);
    });
  }

  void _toggle(int index) {
    setState(() {
      final r = _reminders[index];
      _reminders[index] = r.copyWith(enabled: !r.enabled);
    });
  }

  void _addReminder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddReminderSheet(
        onAdd: (name, time, icon, color) {
          setState(() => _reminders.add(_Reminder(name, time, icon, color, true)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded,
                size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Reminder Settings', style: AppTypography.h4),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Master toggle ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: _masterEnabled
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
                      stops: [0.0, 0.5, 1.0],
                    )
                  : null,
              color: _masterEnabled ? null : context.dColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: _masterEnabled ? AppColors.heroShadow : context.dColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _masterEnabled
                        ? Colors.white.withValues(alpha: 0.15)
                        : context.dColors.surfaceDim,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _masterEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: _masterEnabled ? Colors.white : context.dColors.textTertiary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('All Reminders',
                          style: AppTypography.labelLarge.copyWith(
                              color: _masterEnabled
                                  ? Colors.white
                                  : context.dColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        _masterEnabled ? 'Notifications are on' : 'All paused',
                        style: AppTypography.caption.copyWith(
                            color: _masterEnabled
                                ? Colors.white.withValues(alpha: 0.7)
                                : context.dColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _masterEnabled,
                  onChanged: (v) => setState(() => _masterEnabled = v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.35),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

          const SizedBox(height: 22),

          // ── Repeat days ─────────────────────────────────────────────────
          Text('Repeat On', style: AppTypography.labelLarge)
              .animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: context.dColors.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final dayNum = i == 0 ? 7 : i; // Sun=7 in our set
                final selected = _selectedDays.contains(dayNum);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedDays = {..._selectedDays}..remove(dayNum);
                      } else {
                        _selectedDays = {..._selectedDays}..add(dayNum);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : context.dColors.surfaceDim,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(_dayLabels[i],
                        style: AppTypography.labelMedium.copyWith(
                          color: selected ? Colors.white : context.dColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                );
              }),
            ),
          ).animate().fadeIn(delay: 140.ms, duration: 300.ms),

          const SizedBox(height: 22),

          // ── Reminder list ───────────────────────────────────────────────
          Row(
            children: [
              Text('Scheduled Reminders', style: AppTypography.labelLarge),
              const Spacer(),
              Text('${_reminders.where((r) => r.enabled).length} active',
                  style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
          const SizedBox(height: 12),

          ..._reminders.asMap().entries.map((e) {
            final r = e.value;
            return Opacity(
              opacity: _masterEnabled ? 1 : 0.5,
              child: _ReminderCard(
                reminder: r,
                onToggle: () => _toggle(e.key),
                onEditTime: () => _editTime(e.key),
              ),
            ).animate().fadeIn(delay: (200 + e.key * 60).ms, duration: 300.ms)
                .slideY(begin: 0.05);
          }),

          const SizedBox(height: 16),

          // ── Add reminder ────────────────────────────────────────────────
          GestureDetector(
            onTap: _addReminder,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.dColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_alarm_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Add Reminder',
                      style: AppTypography.button.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 460.ms, duration: 350.ms),
        ],
      ),
    );
  }
}

// ── _Reminder model ───────────────────────────────────────────────────────────

class _Reminder {
  final String title;
  final TimeOfDay time;
  final IconData icon;
  final Color color;
  final bool enabled;
  const _Reminder(this.title, this.time, this.icon, this.color, this.enabled);

  _Reminder copyWith({TimeOfDay? time, bool? enabled}) => _Reminder(
        title, time ?? this.time, icon, color, enabled ?? this.enabled,
      );

  String format(BuildContext context) => time.format(context);
}

// ── _ReminderCard ─────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final _Reminder reminder;
  final VoidCallback onToggle;
  final VoidCallback onEditTime;
  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEditTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: reminder.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(reminder.icon, color: reminder.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onEditTime,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13, color: reminder.color),
                      const SizedBox(width: 4),
                      Text(reminder.format(context),
                          style: AppTypography.caption.copyWith(
                              color: reminder.color, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_rounded,
                          size: 11, color: context.dColors.textTertiary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: reminder.enabled,
            onChanged: (_) => onToggle(),
            activeThumbColor: reminder.color,
          ),
        ],
      ),
    );
  }
}

// ── _AddReminderSheet ─────────────────────────────────────────────────────────

class _AddReminderSheet extends StatefulWidget {
  final void Function(String name, TimeOfDay time, IconData icon, Color color) onAdd;
  const _AddReminderSheet({required this.onAdd});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  static const _presets = [
    ('Custom Reminder', Icons.alarm_rounded, Color(0xFF7C5CFF)),
    ('Hydration', Icons.water_drop_rounded, Color(0xFF06B6D4)),
    ('Mask Day', Icons.face_retouching_natural_rounded, Color(0xFF8B5CF6)),
    ('SPF Reapply', Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
    ('Dermatologist', Icons.medical_services_rounded, Color(0xFF22C55E)),
  ];

  int _selected = 0;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final (presetName, icon, color) = _presets[_selected];
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.dColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('New Reminder', style: AppTypography.h4),
          const SizedBox(height: 18),

          Text('Type', style: AppTypography.labelMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final (name, ic, c) = _presets[i];
                final sel = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 78,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    decoration: BoxDecoration(
                      color: sel ? c.withValues(alpha: 0.12) : context.dColors.surfaceDim,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: sel ? c : Colors.transparent, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ic, color: sel ? c : context.dColors.textSecondary, size: 22),
                        const SizedBox(height: 6),
                        Text(name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                                fontSize: 9,
                                color: sel ? c : context.dColors.textSecondary,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          Text('Name', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: presetName,
              hintStyle: AppTypography.bodyMedium.copyWith(color: context.dColors.textTertiary),
              filled: true,
              fillColor: context.dColors.surfaceDim,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(icon, color: color, size: 18),
            ),
          ),

          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.dColors.surfaceDim,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: color, size: 18),
                  const SizedBox(width: 10),
                  Text('Time', style: AppTypography.labelMedium),
                  const Spacer(),
                  Text(_time.format(context),
                      style: AppTypography.labelMedium.copyWith(color: color)),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded,
                      color: context.dColors.textTertiary, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final name = _controller.text.trim().isEmpty
                  ? presetName
                  : _controller.text.trim();
              widget.onAdd(name, _time, icon, color);
              Navigator.pop(context);
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text('Add Reminder',
                  style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
