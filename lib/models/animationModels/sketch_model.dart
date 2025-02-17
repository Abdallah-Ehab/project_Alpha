import 'dart:ui';

enum SketchMode{
  normal,
  eraser
}
class SketchModel {
  List<Offset> points;
  Color color;
  double strokeWidth;
  SketchMode sketchMode;
  SketchModel({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.sketchMode = SketchMode.normal
  });
}