import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/shelf_models.dart';
import '../../providers/shelf_provider.dart';

const _kCategories = ['Cleanser', 'Moisturizer', 'Serum', 'Sunscreen', 'Treatment', 'Toner', 'Other'];

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int _categoryIdx = 0;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isPurchase}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? (now) : (now.add(const Duration(days: 365))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: context.dColors.textPrimary,
          ), dialogTheme: DialogThemeData(backgroundColor: context.dColors.surface),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isPurchase) {
        _purchaseDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final now = DateTime.now();
    final brand = _brandCtrl.text.trim();
    ref.read(shelfProvider.notifier).addProduct(
          ShelfProduct(
            id: 'u${now.millisecondsSinceEpoch}',
            name: _nameCtrl.text.trim(),
            brand: brand.isEmpty ? 'Unknown' : brand,
            category: _kCategories[_categoryIdx],
            score: 80,
            color: AppColors.primary,
            purchaseDate: _purchaseDate ?? now,
            expiryDate: _expiryDate ?? now.add(const Duration(days: 365)),
            notes: _notesCtrl.text.trim(),
          ),
        );

    setState(() => _saving = false);
    AppSnackbar.success(context, 'Product added to your shelf');
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
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.close_rounded, color: context.dColors.textPrimary, size: 20),
          ),
        ),
        title: Text('Add Product', style: AppTypography.h4),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Save',
                  style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
          children: [
            // Scan shortcut
            _ScanCard()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, duration: 350.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 20),

            // Product details section
            _SectionHeader(title: 'Product Details', icon: Icons.inventory_2_outlined),
            const SizedBox(height: 12),

            _FormCard(
              children: [
                _FieldLabel('Product Name'),
                _InputField(
                  controller: _nameCtrl,
                  hint: 'e.g. Moisture Surge 72H',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter product name' : null,
                ),
                _Divider(),
                _FieldLabel('Brand'),
                _InputField(
                  controller: _brandCtrl,
                  hint: 'e.g. Clinique',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter brand name' : null,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 80.ms, duration: 300.ms)
            .slideY(begin: 0.04, duration: 300.ms),

            const SizedBox(height: 16),

            // Category
            _SectionHeader(title: 'Category', icon: Icons.category_outlined),
            const SizedBox(height: 12),
            _CategoryPicker(
              selected: _categoryIdx,
              onChanged: (i) => setState(() => _categoryIdx = i),
            )
            .animate()
            .fadeIn(delay: 140.ms, duration: 300.ms)
            .slideY(begin: 0.04, duration: 300.ms),

            const SizedBox(height: 16),

            // Dates section
            _SectionHeader(title: 'Dates', icon: Icons.calendar_today_outlined),
            const SizedBox(height: 12),

            _FormCard(
              children: [
                _DateRow(
                  label: 'Purchase Date',
                  icon: Icons.shopping_bag_outlined,
                  date: _purchaseDate,
                  placeholder: 'Tap to select',
                  onTap: () => _pickDate(isPurchase: true),
                ),
                _Divider(),
                _DateRow(
                  label: 'Expiry Date',
                  icon: Icons.event_outlined,
                  date: _expiryDate,
                  placeholder: 'Tap to select',
                  highlight: _expiryDate != null &&
                    _expiryDate!.difference(DateTime.now()).inDays <= 30,
                  onTap: () => _pickDate(isPurchase: false),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .slideY(begin: 0.04, duration: 300.ms),

            // Expiry warning
            if (_expiryDate != null) ...[
              const SizedBox(height: 8),
              _ExpiryWarning(expiryDate: _expiryDate!),
            ],

            const SizedBox(height: 16),

            // Notes section
            _SectionHeader(title: 'Notes', icon: Icons.notes_rounded),
            const SizedBox(height: 12),

            _FormCard(
              children: [
                _InputField(
                  controller: _notesCtrl,
                  hint: 'Any additional notes about this product...',
                  maxLines: 3,
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 260.ms, duration: 300.ms)
            .slideY(begin: 0.04, duration: 300.ms),

            const SizedBox(height: 28),

            // Save button
            SizedBox(
              height: 56,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _saving ? null : AppColors.gradientPrimary,
                  color: _saving ? context.dColors.borderLight : null,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: _saving ? null : AppColors.elevatedShadow,
                ),
                child: TextButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Add to Shelf',
                        style: AppTypography.button.copyWith(color: Colors.white),
                      ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 320.ms, duration: 300.ms)
            .slideY(begin: 0.04, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

// ── _ScanCard ─────────────────────────────────────────────────────────────────

class _ScanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/scan/ingredient'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF3B2D9F), Color(0xFF5E3FFF)],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.heroShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Product',
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Scan barcode or ingredient list to auto-fill',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _CategoryPicker ───────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _CategoryPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_kCategories.length, (i) {
        final sel = selected == i;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: sel ? AppColors.gradientPrimary : null,
              color: sel ? null : context.dColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? Colors.transparent : context.dColors.borderLight,
                width: 1.2,
              ),
              boxShadow: sel ? context.dColors.cardShadow : null,
            ),
            child: Text(
              _kCategories[i],
              style: AppTypography.labelMedium.copyWith(
                color: sel ? Colors.white : context.dColors.textSecondary,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Layout helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: context.dColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
        border: Border.all(color: context.dColors.borderLight, width: 0.8),
      ),
      child: Column(children: children),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: context.dColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: context.dColors.textTertiary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: context.dColors.divider);
  }
}

// ── _DateRow ──────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? date;
  final String placeholder;
  final bool highlight;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.icon,
    required this.date,
    required this.placeholder,
    required this.onTap,
    this.highlight = false,
  });

  static String _fmt(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final textColor = highlight ? AppColors.warning : hasDate ? context.dColors.textPrimary : context.dColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.dColors.textTertiary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(color: context.dColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hasDate ? _fmt(date!) : placeholder,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: context.dColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── _ExpiryWarning ────────────────────────────────────────────────────────────

class _ExpiryWarning extends StatelessWidget {
  final DateTime expiryDate;

  const _ExpiryWarning({required this.expiryDate});

  @override
  Widget build(BuildContext context) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft > 30) return const SizedBox.shrink();

    final isExpired = daysLeft <= 0;
    final color = isExpired ? AppColors.error : AppColors.warning;
    final msg = isExpired
      ? 'This product has already expired.'
      : 'This product expires in $daysLeft day${daysLeft == 1 ? '' : 's'}.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(isExpired ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

