import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';


abstract class Positionable {
  Offset trackPosition;

  Positionable({
    this.trackPosition = const Offset(0.0, 0.0),
  });

  void updatePosition({double? x, double? y});
}




class AnimationTrack extends Positionable with ChangeNotifier {
  String name;
  List<KeyFrame> frames;
  int fps;

  AnimationTrack(this.name, this.frames, {this.fps = 10});

  void addFrame(KeyFrame frame){
    frames.add(frame);
    notifyListeners();
  }
  
  @override
  void updatePosition({double? x, double? y}) {
    trackPosition += Offset(x ?? 0, y ?? 0);
    notifyListeners();
  }
}

class KeyFrame with ChangeNotifier {
  ui.Image? image;
  List<SketchModel> sketches;
  Offset position;
  double rotation;
  double scale;
  KeyFrame({required this.sketches,this.image,this.position = const Offset(0.0,0.0),this.rotation = 0.0,this.scale = 1.0});

  void addSketch(SketchModel sketch){
    sketches.add(sketch);
    notifyListeners();
  }

  void addPointToCurrentSketch(Offset point){
    sketches.last.points.add(point);
    notifyListeners();
  }
  
}