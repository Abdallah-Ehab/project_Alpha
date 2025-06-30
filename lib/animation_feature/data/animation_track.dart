import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/animation_editor/data/sketch_model.dart';







class AnimationTrack with ChangeNotifier {
  String name;
  List<KeyFrame> frames;
  int fps;
  bool isLooping;
  bool mustFinish;

  AnimationTrack(this.name, this.frames,this.isLooping,this.mustFinish, {this.fps = 10});

  AnimationTrack copy(){
    return AnimationTrack(name, frames.map((e)=>e.copy()).toList(), isLooping,mustFinish, fps: fps);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fps': fps,
      'frames': frames.map((frame) => frame.toJson()).toList(),
      'isLooping': isLooping
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
    );
  }

  void setIsLooping(bool isLooping){
  this.isLooping = isLooping;
  notifyListeners();
}

void setMustFinish(bool  mustFinish){
    this.mustFinish = mustFinish;
    notifyListeners();
}

  void addFrame(KeyFrame frame){
    frames.add(frame);
    notifyListeners();
  }

  void removeFrame(int index) {
  if (index >= 0 && index < frames.length) {
    frames.removeAt(index);
    notifyListeners();
  }
}
  KeyFrame removeFrameAt(int index){
    final frame = frames.removeAt(index);
    notifyListeners();
    return frame;
  }

  void insertFrameAt(int index,KeyFrame frame){
    frames.insert(index, frame);
    notifyListeners();
  }

  void addMultipleFrames(List<KeyFrame> frames){
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

  // temporarily holds the base64 string
  String? _imageBase64;

  KeyFrame copy() {
  return KeyFrame(
    sketches: sketches.map((e) => e.copy()).toList(),
    image: image, // still a reference to the same image, safe if immutable
    position: Offset(position.dx,position.dy),
    rotation: rotation,
    scale: scale,
  ).._imageBase64 = _imageBase64; // optional: preserve image data if needed
}


  KeyFrame({
    required this.sketches,
    this.image,
    this.position = const Offset(0, 0),
    this.rotation = 0.0,
    this.scale = 1.0,
  });

  /// Call this **after** fromJson if you need to load the image.
  Future<void> loadImage() async {
    if (_imageBase64 == null) return;
    final bytes = base64Decode(_imageBase64!);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    image = await completer.future;
    notifyListeners();
  }

  /// Since serializing `ui.Image` is async, this remains async.
  Future<Map<String, dynamic>> toJson() async {
    // if we have a live image, re-encode it
    if (image != null) {
      final byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
      _imageBase64 = base64Encode(byteData!.buffer.asUint8List());
    }

    return {
      'image': _imageBase64,
      'sketches': sketches.map((s) => s.toJson()).toList(),
      'position': {'x': position.dx, 'y': position.dy},
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
      ..position = Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      )
      ..rotation = (json['rotation'] as num).toDouble()
      ..scale = (json['scale'] as num).toDouble()
      .._imageBase64 = json['image'] as String?;
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
