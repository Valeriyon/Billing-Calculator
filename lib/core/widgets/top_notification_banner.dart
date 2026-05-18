import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

OverlayEntry? _activeTopNotificationEntry;

void showTopNotification(
  BuildContext context, {
  required String message,
  Color backgroundColor = AppColors.success,
  IconData icon = Icons.check_circle_rounded,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlayState = Overlay.maybeOf(context, rootOverlay: true);

  if (overlayState == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
    return;
  }

  _activeTopNotificationEntry?.remove();
  _activeTopNotificationEntry = null;

  late final OverlayEntry overlayEntry;
  var isRemoved = false;

  void removeEntry() {
    if (isRemoved) return;
    isRemoved = true;
    if (_activeTopNotificationEntry == overlayEntry) {
      _activeTopNotificationEntry = null;
    }
    overlayEntry.remove();
  }

  overlayEntry = OverlayEntry(
    builder: (overlayContext) => _TopNotificationBanner(
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      onDismissed: removeEntry,
    ),
  );

  _activeTopNotificationEntry = overlayEntry;
  overlayState.insert(overlayEntry);
}

class _TopNotificationBanner extends StatefulWidget {
  const _TopNotificationBanner({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color backgroundColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopNotificationBanner> createState() => _TopNotificationBannerState();
}

class _TopNotificationBannerState extends State<_TopNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isClosing) return;
    _isClosing = true;
    _dismissTimer?.cancel();

    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSizes.paddingLarge,
          AppSizes.paddingLarge,
          AppSizes.paddingLarge,
          0,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _controller,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusLarge,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.18),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingLarge,
                          vertical: AppSizes.paddingMedium,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: AppSizes.iconSizeMedium,
                            ),
                            const SizedBox(width: AppSizes.spacingMedium),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
      ),
    );
  }
}
