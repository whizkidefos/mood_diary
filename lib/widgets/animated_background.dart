import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Color color;
  final double opacity;

  const AnimatedBackground({
    super.key,
    required this.color,
    this.opacity = 0.05,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _numPatterns = 5;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _numPatterns,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + _random.nextInt(2000)),
        vsync: this,
      )..repeat(reverse: true),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.5,
        end: 1.5,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_numPatterns, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: _random.nextDouble() * MediaQuery.of(context).size.width,
              top: _random.nextDouble() * MediaQuery.of(context).size.height,
              child: Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(widget.opacity),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
