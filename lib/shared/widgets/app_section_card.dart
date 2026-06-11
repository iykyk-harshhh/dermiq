import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// White rounded card with an optional overline header and a column of rows.
///
/// Replaces the repeated `_Group` / `_Section` / `_Card` / `_PrefCard`
/// private classes across settings, profile and detail screens.
class AppSectionCard extends StatelessWidget {
  final String? title;
  final String? hint;
  final Widget? trailing;
  final List<Widget> children;

  /// `true` → uppercase overline header (settings groups).
  /// `false` → `labelLarge` heading (content / edit sections).
  final bool overline;

  /// Inner padding around [children]. When omitted, defaults to zero for
  /// overline groups (rows self-pad) and `(16,0,16,16)` for content cards.
  final EdgeInsetsGeometry? padding;

  const AppSectionCard({
    super.key,
    this.title,
    this.hint,
    this.trailing,
    required this.children,
    this.overline = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null;
    final childPadding = padding ??
        (overline ? EdgeInsets.zero : const EdgeInsets.fromLTRB(16, 0, 16, 16));

    return Container(
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.dColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader)
            Padding(
              padding: overline
                  ? const EdgeInsets.fromLTRB(16, 14, 16, 6)
                  : const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      overline ? title!.toUpperCase() : title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: overline
                          ? AppTypography.overline.copyWith(
                              color: AppColors.primary, letterSpacing: 1.4)
                          : AppTypography.labelLarge,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(hint!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption
                              .copyWith(color: context.dColors.textTertiary)),
                    ),
                  ],
                  if (trailing != null) ...[const Spacer(), trailing!],
                ],
              ),
            ),
          Padding(
            padding: childPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          if (overline && hasHeader) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// A thin inset divider matching the settings/preferences look.
class AppRowDivider extends StatelessWidget {
  final double indent;
  const AppRowDivider({super.key, this.indent = 66});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: indent, right: 16),
        child: Divider(color: context.dColors.borderLight, height: 1),
      );
}

/// Icon + label + subtitle + Switch row. Replaces the `_Toggle` / `_ToggleRow`
/// copies in settings, notifications, privacy and preferences.
class AppToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool divider;

  const AppToggleTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.divider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTypography.labelMedium),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: AppTypography.caption.copyWith(
                              color: context.dColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(value: value, onChanged: onChanged, activeThumbColor: color),
            ],
          ),
        ),
        if (divider) const AppRowDivider(),
      ],
    );
  }
}

/// Navigable settings/menu row: icon tile + label (+ optional subtitle/value)
/// + trailing chevron. Replaces `_Row`, `_MenuTile`, `_LinkRow`, `_ActionRow`.
class AppSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackground;
  final String label;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;
  final bool divider;
  final bool danger;
  final IconData trailingIcon;

  const AppSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.iconBackground,
    this.subtitle,
    this.value,
    this.divider = true,
    this.danger = false,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final ic = danger ? AppColors.error : (iconColor ?? AppColors.primary);
    final labelColor = danger ? AppColors.error : context.dColors.textPrimary;
    return Column(
      children: [
        Semantics(
          button: true,
          label: label,
          child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: iconBackground ?? ic.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: ic, size: 19),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTypography.labelMedium
                              .copyWith(color: labelColor)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: AppTypography.caption.copyWith(
                                color: context.dColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                if (value != null) ...[
                  Text(value!,
                      style: AppTypography.caption
                          .copyWith(color: context.dColors.textTertiary)),
                  const SizedBox(width: 6),
                ],
                Icon(trailingIcon, color: context.dColors.textTertiary, size: 20),
              ],
            ),
          ),
        )),
        if (divider) const AppRowDivider(indent: 65),
      ],
    );
  }
}
