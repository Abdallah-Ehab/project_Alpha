

// Custom painter for command blocks (e.g., Play Animation, Move);

import 'package:flutter/material.dart';

class CommandBlockPainter extends CustomPainter {
  final Color color;
  final double notchSize = 10.0;

  CommandBlockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path()
      // Start at top-left
      ..moveTo(0, notchSize)
      // Top-left corner
      ..quadraticBezierTo(0, 0, notchSize, 0)
      // Top edge with bump
      ..lineTo(size.width - notchSize, 0)
      // Top-right corner
      ..quadraticBezierTo(size.width, 0, size.width, notchSize)
      // Right edge
      ..lineTo(size.width, size.height - notchSize)
      // Bottom-right corner
      ..quadraticBezierTo(size.width, size.height, size.width - notchSize, size.height)
      // Bottom edge with notch (for connecting blocks below)
      ..lineTo(notchSize + 15, size.height)
      // Notch
      ..lineTo(notchSize + 10, size.height - 5)
      ..lineTo(notchSize + 5, size.height)
      ..lineTo(notchSize, size.height)
      // Bottom-left corner
      ..quadraticBezierTo(0, size.height, 0, size.height - notchSize)
      // Left edge
      ..lineTo(0, notchSize + 15)
      // Notch in left side (for connecting blocks)
      ..lineTo(5, notchSize + 10)
      ..lineTo(0, notchSize + 5)
      ..close();

    // Apply a subtle shadow
    canvas.drawShadow(path, Colors.black54, 2.0, true);
    canvas.drawPath(path, paint);

    // Add a slight bevel effect with a slightly darker color
    final Paint bevelPaint = Paint()
      ..color = color.withValues(alpha:0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, bevelPaint);
  }

  @override
  bool shouldRepaint(CommandBlockPainter oldDelegate) => color != oldDelegate.color;
}



