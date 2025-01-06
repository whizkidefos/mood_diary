import 'package:flutter/material.dart';

class SocialCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const SocialCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 0,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
