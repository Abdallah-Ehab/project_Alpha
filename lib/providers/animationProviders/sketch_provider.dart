import 'package:flutter/material.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';

class SketchProvider extends ChangeNotifier {
  int _currentsketchIndex = 0;
  double _currentStrokeWidth = 1.0;
  Color _currentColor = Colors.black;
  SketchMode _currentSketchMode = SketchMode.normal;
  SketchModel _currentSketch = SketchModel(
      sketchMode: SketchMode.normal,
      points: [],
      color: Colors.black,
      strokeWidth: 1.0);
  List<SketchModel> allSketches = [];

  double get currentStrokeWidth => _currentStrokeWidth;

  set currentStrokeWidth(double strokeWidth) {
    _currentStrokeWidth = strokeWidth;
    notifyListeners();
  }

  set currentColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  Color get currentColor => _currentColor;

  set currentsketchMode(SketchMode mode) {
    _currentSketchMode = mode;
    notifyListeners();
  }

  SketchMode get currentsketchMode => _currentSketchMode;

  void addPoint(Offset point) {
    _currentSketch.points.add(point);
    notifyListeners();
  }

  SketchModel get currentSketch => _currentSketch;

  set currentSketch(SketchModel newSketch) {
    _currentSketch = newSketch;
    notifyListeners();
  }

  void setColor(Color newColor) {
    _currentSketch.color = newColor;
    notifyListeners();
  }

  void setStrokeWidth(double newStrokeWidth) {
    _currentSketch.strokeWidth = newStrokeWidth;
    notifyListeners();
  }

  void clearPoints() {
    _currentSketch.points = [];
    notifyListeners();
  }

  void addCurrentSketch() {
    allSketches.add(_currentSketch);
    notifyListeners();
  }

  void clearAllSketches() {
    allSketches.clear();
    notifyListeners();
  }

  int get currentSketchIndex => _currentsketchIndex;

  set currentSketchIndex(int index) {
    _currentsketchIndex = index;
    notifyListeners();
  }
}
