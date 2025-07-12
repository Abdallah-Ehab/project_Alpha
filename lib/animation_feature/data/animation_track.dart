import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';







class AnimationTrack with ChangeNotifier {
  String name;
  List<KeyFrame> frames;
  Offset position;
  int fps;
  bool isLooping;
  bool mustFinish;
  bool isDestroyAnimationTrack; 

  AnimationTrack(this.name, this.frames, this.isLooping, this.mustFinish,
      {this.fps = 10, this.isDestroyAnimationTrack = false,this.position = Offset.zero});

  AnimationTrack copy() {
    return AnimationTrack(name, frames.map((e) => e.copy()).toList(), 
        isLooping, mustFinish, 
        fps: fps, isDestroyAnimationTrack: isDestroyAnimationTrack);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fps': fps,
      'position' : {'dx':position.dx, 'dy' : position.dy},
      'frames': frames.map((frame) => frame.toJson()).toList(),
      'isLooping': isLooping,
      'mustFinish': mustFinish,
      'isDestroyAnimationTrack': isDestroyAnimationTrack,
    };
  }

  factory AnimationTrack.fromJson(Map<String, dynamic> json) {
    return AnimationTrack(
      json['name'] as String,
      (json['frames'] as List<dynamic>)
          .map((e) => KeyFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['isLooping'],
      json['mustFinish'], 
      fps: json['fps'] as int? ?? 10,
      position: OffsetJson.fromJson(json['position']),
      isDestroyAnimationTrack: json['isDestroyAnimationTrack'] as bool? ?? false,
    );
  }

  void setPosition(Offset position){
    this.position = position;
    notifyListeners();
  }

  void setIsLooping(bool isLooping) {
    this.isLooping = isLooping;
    notifyListeners();
  }

  void setMustFinish(bool mustFinish) {
    this.mustFinish = mustFinish;
    notifyListeners();
  }

  void setIsDestroyAnimationTrack(bool isDestroyAnimationTrack) {
    this.isDestroyAnimationTrack = isDestroyAnimationTrack;
    notifyListeners();
  }

  void addFrame(KeyFrame frame) {
    frames.add(frame);
    notifyListeners();
  }

  void removeFrame(int index) {
    if (index >= 0 && index < frames.length) {
      frames.removeAt(index);
      notifyListeners();
    }
  }

  KeyFrame removeFrameAt(int index) {
    final frame = frames.removeAt(index);
    notifyListeners();
    return frame;
  }

  void insertFrameAt(int index, KeyFrame frame) {
    frames.insert(index, frame);
    notifyListeners();
  }

  void addMultipleFrames(List<KeyFrame> frames) {
    this.frames.addAll(frames);
    notifyListeners();
  }
}
class KeyFrame with ChangeNotifier {
  ui.Image? image;
  List<SketchModel> sketches;
  Offset position;
  double rotation;
  double scale;
  String? imageBase64;

  KeyFrame copy() {
  return KeyFrame(
    sketches: sketches.map((e) => e.copy()).toList(),
    image: image, // still a reference to the same image, safe if immutable
    position: Offset(position.dx,position.dy),
    rotation: rotation,
    scale: scale,
    imageBase64: imageBase64,
  );
}


  KeyFrame({
    required this.sketches,
    this.image,
    this.position = const Offset(0, 0),
    this.rotation = 0.0,
    this.scale = 1.0,
    this.imageBase64,
  });


  
  Map<String, dynamic> toJson(){
    return {
      'image': imageBase64,
      'sketches': sketches.map((s) => s.toJson()).toList(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'rotation': rotation,
      'scale': scale,
    };
  }

  factory KeyFrame.fromJson(Map<String, dynamic> json) {
    return KeyFrame(
      sketches: (json['sketches'] as List<dynamic>)
          .map((e) => SketchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      // leave image null for now
    )
      ..position = OffsetJson.fromJson(json['position'])
      ..rotation = (json['rotation'] as num).toDouble()
      ..scale = (json['scale'] as num).toDouble()
      ..imageBase64 = json['image'] as String?
      ..image = null;
  }


  void addSketch(SketchModel sketch){
    sketches.add(sketch);
    notifyListeners();
  }

  void addPointToCurrentSketch(Offset point){
    sketches.last.points.add(point);
    notifyListeners();
  }

  void removePointFromSketch(Offset point) {
  const double threshold = 20.0;

  sketches.removeWhere((sketch) {
    sketch.points.removeWhere((p) => (point - p).distance <= threshold);
    return sketch.points.isEmpty;
  });

  notifyListeners();
}


}



Future<ui.Image> base64ToImage(String base64Str) async {
  final Uint8List bytes = base64Decode(base64Str);
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
  return completer.future;
}

Future<String?> imageToBase64(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return null;
  final bytes = byteData.buffer.asUint8List();
  return base64Encode(bytes);
}