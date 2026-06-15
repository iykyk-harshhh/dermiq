import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// iOS-style drop-in notification banner — modelled on the Jitter
/// "Simple Notification [iOS]" template: a frosted rounded card that springs
/// down from the top with an app icon, title and message, auto-dismisses, and
/// can be flicked up to dismiss early.
///
/// Usage:
/// ```dart
/// IosNotification.show(
///   context,
///   title: 'Order Confirmed',
///   message: 'Your order #DQ12AB is on its way.',
///   icon: Icons.local_shipping_rounded,
/// );
/// ```
class IosNotification {
  const IosNotification._();

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.notifications_rounded,
    Color color = AppColors.primary,
    String appName = 'DermIQ',
    Duration duration = const Duration(milliseconds: 3800),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    var removed = false;
    void remove() {
      if (removed) return;
      removed = true;
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (_) => _IosBanner(
        title: title,
        message: message,
        icon: icon,
        color: color,
        appName: appName,
        duration: duration,
        onTap: onTap,
        onDismiss: remove,
      ),
    );
    overlay.insert(entry);
  }
}

class _IosBanner extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String appName;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _IosBanner({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.appName,
    required this.duration,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_IosBanner> createState() => _IosBannerState();
}

class _IosBannerState extends State<_IosBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutBack, // spring drop with a little overshoot
      reverseCurve: Curves.easeInCubic,
    ));
    _fade = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _c.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    if (mounted) await _c.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.dColors;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                  _dismiss();
                },
                // Flick up to dismiss.
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < 0) _dismiss();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // App icon (rounded-square, iOS style).
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.color,
                                  widget.color.withValues(alpha: 0.72),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(widget.icon,
                                color: Colors.white, size: 21),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.appName.toUpperCase(),
                                        style: AppTypography.overline.copyWith(
                                          color: c.textTertiary,
                                          letterSpacing: 0.6,
                                          fontSize: 9.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'now',
                                      style: AppTypography.caption.copyWith(
                                        color: c.textTertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  widget.title,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.message,
                                  style: AppTypography.caption.copyWith(
                                    color: c.textSecondary,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
