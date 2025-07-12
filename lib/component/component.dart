// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';
import 'package:scratch_clone/pose_detection_feature/data/pose_detection_component.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';


abstract class Component with ChangeNotifier {
  bool isActive;

  Component({this.isActive = true});


  Component copy();

   Map<String, dynamic> toJson();


  void update(Duration dt, {required Entity activeEntity});

  void reset();

  void toggleComponent() {
    isActive = !isActive;
    notifyListeners();
  }

  static Component fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw Exception('Component type is missing from JSON.');
    }

    switch (type) {
      case 'animation_controller':
        return AnimationControllerComponent.fromJson(json);
      case 'sound':
        return SoundControllerComponent.fromJson(json);
      case 'collider_component':
        return ColliderComponent.fromJson(json);
      case 'rigidbody_component':
        return RigidBodyComponent.fromJson(json);
      case 'node_component':
        return NodeComponent.fromJson(json);
      case "SoundControllerComponent":
        return SoundControllerComponent.fromJson(json);
      default:
        throw Exception('Unknown component type: $type');
    }
  }
}
