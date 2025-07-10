import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/pose_detection_feature/data/pose_detection_component.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

class ComponentFactory {
  static Component fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'NodeComponent':
        return NodeComponent.fromJson(json);
      case 'AnimationControllerComponent':
        return AnimationControllerComponent.fromJson(json);
      case "SoundControllerComponent":
        return SoundControllerComponent.fromJson(json);
      // Add more components here
      default:
        throw UnimplementedError('Unknown component type: $type');
    }
  }
}
