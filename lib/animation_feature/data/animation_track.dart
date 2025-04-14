import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';

class AnimationTrack extends ChangeNotifier {
  String name;
  List<KeyFrame> frames;
  int fps;

  AnimationTrack(this.name, this.frames, {this.fps = 10});

  void addFrame(KeyFrame frame){
    frames.add(frame);
    notifyListeners();
  }
}

class KeyFrame extends ChangeNotifier{
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