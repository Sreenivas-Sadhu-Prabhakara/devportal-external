import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';

/// Centers page content and caps its width, with consistent horizontal gutters.
class ContentWrap extends StatelessWidget {
  const ContentWrap({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxContent,
    this.padding = const EdgeInsets.symmetric(horizontal: 48),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
