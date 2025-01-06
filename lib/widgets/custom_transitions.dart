import 'package:flutter/material.dart';
import 'dart:math';

class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType type;

  SharedAxisPageRoute({
    required this.page,
    this.type = SharedAxisTransitionType.horizontal,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final begin = type == SharedAxisTransitionType.horizontal
                ? const Offset(1.0, 0.0)
                : type == SharedAxisTransitionType.vertical
                    ? const Offset(0.0, 1.0)
                    : Offset.zero;

            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            if (type == SharedAxisTransitionType.scaled) {
              return ScaleTransition(
                scale: Tween<double>(
                  begin: 0.9,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: curve,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            }

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset center;

  CircularRevealRoute({
    required this.page,
    required this.center,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return ClipPath(
              clipper: CircularRevealClipper(
                fraction: animation.value,
                center: center,
              ),
              child: child,
            );
          },
        );
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  CircularRevealClipper({
    required this.fraction,
    required this.center,
  });

  @override
  Path getClip(Size size) {
    final radius = _calcMaxRadius(size);
    final path = Path();

    if (fraction == 0) {
      path.addRect(
        Rect.fromLTWH(center.dx, center.dy, 0, 0),
      );
    } else {
      path.addOval(
        Rect.fromCircle(
          center: center,
          radius: radius * fraction,
        ),
      );
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

  double _calcMaxRadius(Size size) {
    final w = size.width;
    final h = size.height;
    final dx = center.dx.abs();
    final dy = center.dy.abs();
    final maxDx = dx > w - dx ? dx : w - dx;
    final maxDy = dy > h - dy ? dy : h - dy;
    return sqrt(maxDx * maxDx + maxDy * maxDy);
  }
}

class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset offset;

  const SlideFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.offset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            offset.dx * (1 - animation.value) * 100,
            offset.dy * (1 - animation.value) * 100,
          ),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
