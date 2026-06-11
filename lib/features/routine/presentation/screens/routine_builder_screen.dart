import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../data/routine_models.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late List<RoutineStep> _amSteps;
  late List<RoutineStep> _pmSteps;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _amSteps = List.of(amSteps);
    _pmSteps = List.of(pmSteps);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _reorder(int old, int nw, {required bool isAm}) {
    setState(() {
      final list = isAm ? _amSteps : _pmSteps;
      // onReorderItem already adjusts newIndex for the removed item.
      final item = list.removeAt(old);
      list.insert(nw, item);
    });
  }

  void _remove(String id, {required bool isAm}) {
    setState(() {
      final list = isAm ? _amSteps : _pmSteps;
      list.removeWhere((s) => s.id == id);
    });
  }

  Future<void> _addStep() async {
    final isAm = _tab.index == 0;
    final result = await showModalBottomSheet<RoutineStep>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddStepSheet(isAm: isAm),
    );
    if (result == null) return;
    setState(() {
      final list = isAm ? _amSteps : _pmSteps;
      list.add(result);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Routine saved!',
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        backgroundColor: context.dColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: context.dColors.surfaceDim, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.arrow_back_rounded, size: 20, color: context.dColors.textPrimary),
          ),
        ),
        title: Text('Routine Builder', style: AppTypography.h4),
        actions: [
          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Text('Save', style: AppTypography.buttonSmall.copyWith(color: Colors.white)),
            ),
          ),
        ],
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
              tabs: const [
                Tab(text: 'AM Routine'),
                Tab(text: 'PM Routine'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _StepList(
            steps: _amSteps,
            isAm: true,
            onReorder: (o, n) => _reorder(o, n, isAm: true),
            onRemove: (id) => _remove(id, isAm: true),
          ),
          _StepList(
            steps: _pmSteps,
            isAm: false,
            onReorder: (o, n) => _reorder(o, n, isAm: false),
            onRemove: (id) => _remove(id, isAm: false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStep,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Step', style: AppTypography.buttonSmall.copyWith(color: Colors.white)),
      ),
    );
  }
}

// ── _StepList (reorderable) ───────────────────────────────────────────────────

class _StepList extends StatelessWidget {
  final List<RoutineStep> steps;
  final bool isAm;
  final void Function(int, int) onReorder;
  final void Function(String) onRemove;

  const _StepList({
    required this.steps,
    required this.isAm,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add_rounded, size: 56, color: context.dColors.textTertiary),
            const SizedBox(height: 12),
            Text('No steps yet',
                style: AppTypography.labelLarge.copyWith(color: context.dColors.textTertiary)),
            const SizedBox(height: 6),
            Text('Tap + Add Step below',
                style: AppTypography.bodySmall.copyWith(color: context.dColors.textTertiary)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Text(
                '${steps.length} step${steps.length == 1 ? '' : 's'} · '
                '~${steps.fold(0, (s, e) => s + e.durationMin)} min total',
                style: AppTypography.caption.copyWith(color: context.dColors.textSecondary),
              ),
              const Spacer(),
              Icon(Icons.drag_handle_rounded, size: 16, color: context.dColors.textTertiary),
              const SizedBox(width: 4),
              Text('Hold to reorder',
                  style: AppTypography.caption.copyWith(color: context.dColors.textTertiary)),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemCount: steps.length,
            onReorderItem: onReorder,
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              child: child,
            ),
            itemBuilder: (context, i) {
              final step = steps[i];
              return _BuilderStepCard(
                key: ValueKey(step.id),
                step: step,
                index: i,
                onRemove: () => onRemove(step.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── _BuilderStepCard ──────────────────────────────────────────────────────────

class _BuilderStepCard extends StatelessWidget {
  final RoutineStep step;
  final int index;
  final VoidCallback onRemove;

  const _BuilderStepCard({
    super.key,
    required this.step,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.dColors.borderLight),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: AppTypography.caption.copyWith(
                    color: step.color, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(step.icon, color: step.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.stepType,
                    style: AppTypography.caption.copyWith(
                        color: step.color, fontWeight: FontWeight.w600)),
                Text(step.productName, style: AppTypography.labelMedium),
                Text('~${step.durationMin} min',
                    style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmRemove(context),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 17),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.drag_indicator_rounded,
              color: context.dColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Step?', style: AppTypography.h4),
        content: Text('Remove "${step.productName}" from your routine?',
            style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTypography.buttonSmall.copyWith(color: context.dColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove();
            },
            child: Text('Remove',
                style: AppTypography.buttonSmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── _AddStepSheet ─────────────────────────────────────────────────────────────

class _AddStepSheet extends StatefulWidget {
  final bool isAm;
  const _AddStepSheet({required this.isAm});

  @override
  State<_AddStepSheet> createState() => _AddStepSheetState();
}

class _AddStepSheetState extends State<_AddStepSheet> {
  static const _types = [
    ('Cleanse',     Icons.water_drop_rounded,                    Color(0xFF06B6D4)),
    ('Tone',        Icons.science_rounded,                       Color(0xFF8B5CF6)),
    ('Treat',       Icons.biotech_rounded,                       Color(0xFF7C5CFF)),
    ('Moisturize',  Icons.spa_rounded,                           Color(0xFF22C55E)),
    ('Protect',     Icons.wb_sunny_rounded,                      Color(0xFFF59E0B)),
    ('Oil Cleanse', Icons.cleaning_services_rounded,             Color(0xFFEC4899)),
    ('Exfoliate',   Icons.blur_on_rounded,                       Color(0xFFFF6B7A)),
    ('Eye Care',    Icons.remove_red_eye_rounded,                Color(0xFF06B6D4)),
    ('Mask',        Icons.face_retouching_natural_rounded,       Color(0xFF8B5CF6)),
  ];

  int _selected = 0;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (type, icon, color) = _types[_selected];
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
          Text('Add a Step', style: AppTypography.h4),
          Text('${widget.isAm ? 'AM' : 'PM'} Routine',
              style: AppTypography.caption.copyWith(color: context.dColors.textSecondary)),
          const SizedBox(height: 20),

          Text('Step Type', style: AppTypography.labelMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final (t, ic, c) = _types[i];
                final sel = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
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
                        Icon(ic,
                            color: sel ? c : context.dColors.textSecondary, size: 22),
                        const SizedBox(height: 5),
                        Text(t,
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
          Text('Product Name', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'e.g. CeraVe Hydrating Cleanser',
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

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final name = _controller.text.trim();
              if (name.isEmpty) return;
              final id =
                  '${widget.isAm ? 'am' : 'pm'}_${DateTime.now().millisecondsSinceEpoch}';
              Navigator.pop(
                context,
                RoutineStep(
                  id: id,
                  stepType: type,
                  productName: name,
                  description: '${type.toLowerCase()} step',
                  tip: 'Follow product instructions for best results',
                  icon: icon,
                  color: color,
                  durationMin: 1,
                ),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Text('Add Step',
                  style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
