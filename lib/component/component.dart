// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/block_feature/data/block_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';

import '../physics_feature/data/collider_component.dart';

abstract class Component with ChangeNotifier {
  bool isActive;

  Component({this.isActive = true});

  factory Component.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'Animation':
        return AnimationControllerComponent().fromJson(
            json);
      case 'camera':
        return BlockComponent().fromJson(
            json);
      default:
        throw Exception('Unknown entity type');
    }
  }

  Map<String, dynamic> toJson();

  void update(Duration dt, {required Entity activeEntity});

  void reset();

  void toggleComponent() {
    isActive = !isActive;
    notifyListeners();
  }
}

// class ComponentMapConverter
//     implements JsonConverter<Map<Type, Component>, Map<String, dynamic>> {
//   const ComponentMapConverter();
//
//   @override
//   Map<Type, Component> fromJson(Map<String, dynamic> json) {
//     return json.map((typeString, componentJson) {
//       // Convert the string key back to a Type
//       final type = _stringToType(typeString);
//       // Deserialize the component
//       final component = Component.fromJson(componentJson) as Component;
//       return MapEntry(type, component);
//     });
//   }
//
//   @override
//   Map<String, dynamic> toJson(Map<Type, Component> components) {
//     return components.map((type, component) {
//       // Convert the Type key to a string
//       final typeString = _typeToString(type);
//       // Serialize the component
//       final componentJson = component.toJson();
//       return MapEntry(typeString, componentJson);
//     });
//   }
//
//   // Helper: Map Type to String (e.g., "ColliderComponent")
//   String _typeToString(Type type) => type.toString();
//
//   // Helper: Map String to Type (e.g., "ColliderComponent" -> ColliderComponent)
//   Type _stringToType(String typeString) {
//     switch (typeString) {
//       case 'ColliderComponent':
//         return ColliderComponent;
//       case 'AnimationControllerComponent':
//         return AnimationControllerComponent;
//       case 'BlockComponent':
//         return BlockComponent;
//       case 'RigidBodyComponent':
//         return RigidBodyComponent;
//
//       default:
//         throw UnsupportedError('Unknown component type: $typeString');
//     }
//   }
// }
