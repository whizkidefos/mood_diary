import 'package:flutter/material.dart';

class HeroIcon extends StatelessWidget {
  final String tag;
  final IconData icon;
  final Color color;
  final double size;
  final Color? backgroundColor;

  const HeroIcon({
    super.key,
    required this.tag,
    required this.icon,
    required this.color,
    this.size = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
