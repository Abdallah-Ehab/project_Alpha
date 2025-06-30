import 'package:flutter/cupertino.dart';

class SketchModel {
  List<Offset> points;
  Color color;
  double strokeWidth;

  SketchModel({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  SketchModel copy() {
    return SketchModel(
        points: points
            .map((point) => Offset(point.dx, point.dy))
            .toList(), // deep copy
        color: color,
        strokeWidth: strokeWidth);
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points
          .map((pt) => {
                'x': pt.dx,
                'y': pt.dy,
              })
          .toList(),
      'color': color,
      'strokeWidth': strokeWidth,
    };
  }

  factory SketchModel.fromJson(Map<String, dynamic> json) {
    return SketchModel(
      points: (json['points'] as List<dynamic>)
          .map((e) => Offset(
                (e['x'] as num).toDouble(),
                (e['y'] as num).toDouble(),
              ))
          .toList(),
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );
  }
}
