import 'package:flutter/material.dart';

import 'package:scratch_clone/models/animationModels/sketch_model.dart';

class ThumbnailWidget extends StatelessWidget {
  final List<SketchModel> sketches;
  const ThumbnailWidget({super.key, required this.sketches});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,  // Adjust size as needed
      height: 80, 
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: CustomPaint(
        painter: ThumbnailPainter(sketches),
      ),
    );
  }
}

class ThumbnailPainter extends CustomPainter {
  final List<SketchModel> sketches;
  ThumbnailPainter(this.sketches);

  @override
  void paint(Canvas canvas, Size size) {
    for (var sketch in sketches) {
      Paint paint = Paint()
        ..color = sketch.color
        ..strokeWidth = sketch.strokeWidth / 4  // Scale down stroke width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < sketch.points.length - 1; i++) {
        Offset start = sketch.points[i] * 0.1; // Scale down points
        Offset end = sketch.points[i + 1] * 0.1;
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}