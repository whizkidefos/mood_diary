import 'package:flutter/material.dart';

class AnimatedGradientBox extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBox({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientBox> createState() => _AnimatedGradientBoxState();
}

class _AnimatedGradientBoxState extends State<AnimatedGradientBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft.add(
                Alignment(_controller.value, _controller.value),
              ),
              end: Alignment.bottomRight.add(
                Alignment(-_controller.value, -_controller.value),
              ),
              colors: widget.colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
