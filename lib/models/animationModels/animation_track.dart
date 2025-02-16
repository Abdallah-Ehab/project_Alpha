import 'package:scratch_clone/models/animationModels/key_frame_model.dart';

class AnimationTrack {
  String name;
  List<KeyframeModel> keyFrames;
  double duration;
  final List<int> fullKeyFramesIndices = [0]; 
  AnimationTrack({
    required this.name,
    required this.keyFrames,
    required this.duration,
  });

  void addToFullKeyFrameIndices(int index){
    fullKeyFramesIndices.add(index);
    fullKeyFramesIndices.sort();
  }
}