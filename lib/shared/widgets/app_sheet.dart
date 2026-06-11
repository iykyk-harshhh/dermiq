import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'section_header.dart';

/// Opens a modal bottom sheet with the standard DermIQ chrome (transparent
/// barrier so the rounded [AppSheet] shows through). Replaces the repeated
/// `showModalBottomSheet(backgroundColor: Colors.transparent, ...)` calls.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    builder: builder,
  );
}

/// White rounded-top sheet container with an optional grab handle and title.
/// Handles bottom safe-area and keyboard insets automatically.
class AppSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool handle;
  final EdgeInsets? padding;

  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.handle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final safe = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: (padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 20))
          .add(EdgeInsets.only(bottom: insets + safe)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (handle) const SheetHandle(),
          if (title != null) ...[
            const SizedBox(height: 6),
            Text(title!, style: AppTypography.h4),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
