import 'dart:math';
import 'package:flutter/material.dart';

class PixelStar {
  Offset position;
  double speed;
  Offset direction;

  PixelStar({
    required this.position,
    required this.speed,
    required this.direction,
  });

  void move(Size screenSize) {
    position += direction * speed;

    // Reset star if it moves off-screen
    if (position.dx > screenSize.width || position.dy > screenSize.height) {
      reset(screenSize, initial: false);
    }
  }

  void reset(Size screenSize, {bool initial = false}) {
    // Semi-parallel direction (30° ± 10°)
    double baseAngle = pi / 6; // 30 degrees
    double variation = (Random().nextDouble() - 0.5) * (pi / 18); // ±10 degrees
    double angle = baseAngle + variation;

    direction = Offset(cos(angle), sin(angle));
    speed = 1 + Random().nextDouble() * 2;

    if (initial) {
      // 🌟 Start inside the screen
      position = Offset(
        Random().nextDouble() * screenSize.width,
        Random().nextDouble() * screenSize.height,
      );
    } else {
      // 🌠 Re-enter from top or left
      bool fromLeft = Random().nextBool();
      if (fromLeft) {
        position = Offset(
          -10,
          Random().nextDouble() * screenSize.height,
        );
      } else {
        position = Offset(
          Random().nextDouble() * screenSize.width,
          -10,
        );
      }
    }
  }
}

class ShootingStarsPainter extends CustomPainter {
  final List<PixelStar> stars;

  ShootingStarsPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      canvas.drawRect(
        Rect.fromLTWH(star.position.dx, star.position.dy, 2, 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ShootingStarsBackground extends StatefulWidget {
  const ShootingStarsBackground({super.key});

  @override
  _ShootingStarsBackgroundState createState() =>
      _ShootingStarsBackgroundState();
}

class _ShootingStarsBackgroundState extends State<ShootingStarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<PixelStar> _stars;

  @override
  void initState() {
    super.initState();

    final screenSize = WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;

    _stars = List.generate(100, (_) => PixelStar(
      position: Offset.zero,
      speed: 0,
      direction: Offset.zero,
    ));

    for (var star in _stars) {
      star.reset(screenSize, initial: true); // 🌌 spread out on load
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1000),
    )
      ..addListener(() {
        setState(() {
          for (var star in _stars) {
            star.move(screenSize);
          }
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShootingStarsPainter(_stars),
      child: Container(),
    );
  }
}
