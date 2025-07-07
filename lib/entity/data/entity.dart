import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scratch_clone/camera_feature/data/camera_entity.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/light_entity.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';

import 'actor_entity.dart';

enum Property { name, position, rotation, width, height, layerNumber }

abstract class Entity with ChangeNotifier {
  String name;
  ui.Offset position;
  double rotation;
  double width;
  double height;
  double widthScale;
  double heigthScale;
  Map<Type, List<Component>> components;
  Map<String, dynamic> variables;
  Map<String, List<dynamic>> lists;
  int layerNumber;
  bool onTapVariable;
  bool onLongPressVariable;
  bool onDoubleTapVariable;

  Entity({
    required this.name,
    required this.position,
    required this.rotation,
    this.widthScale = 1.0,
    this.heigthScale = 1.0,
    this.width = 100,
    this.height = 100,
    this.layerNumber = 0,
    this.onDoubleTapVariable = false,
    this.onTapVariable = false,
    this.onLongPressVariable = false
  }):components = {},variables = {},lists = {};

  dynamic getProperty(Property property) {
    switch (property) {
      case Property.name:
        return name;
      case Property.position:
        return position;
      case Property.height:
        return height * heigthScale;
      case Property.rotation:
        return rotation;
      case Property.width:
        return width * widthScale;
      case Property.layerNumber:
        return layerNumber;
    }
  }

  Entity copy();
  // Custom serialization for Offset field
  static Map<String, dynamic> offsetToJson(ui.Offset offset) {
    return {
      'x': offset.dx,
      'y': offset.dy,
  };
  }

  void setOnTapVariable(bool value){
    onTapVariable = value;
    notifyListeners();
  }

  void setOnDoubleTapVariable(bool value){
    onDoubleTapVariable = value;
    notifyListeners();
  }

  void setOnLongPressVariable(bool value){
    onLongPressVariable = value;
    notifyListeners();
  }

  // Convert the 'ui.Offset' from a Map during deserialization
  static ui.Offset offsetFromJson(Map<String, dynamic> json) {
    return ui.Offset(json['x'], json['y']);
  }

  factory Entity.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'actor':
        return ActorEntity.fromJson(
            json); // Replace with your specific Entity subclasses
      case 'camera':
        return CameraEntity.fromJson(
            json); // Replace with your specific Entity subclasses
      case 'light':
      return LightEntity.fromJson(json);
      default:
        throw Exception('Unknown entity type');
    }
  }

  Map<String, dynamic> toJson();

  void addComponent(Component component) {
    if (component is ColliderComponent) {
      component.position = position;
      component.width = width;
      component.height = height;
    }
    final type = component.runtimeType;

    components.putIfAbsent(type, () => []);
    components.putIfAbsent(component.runtimeType, () => []);
    final isNode = type == NodeComponent;
    final alreadyExists = components[type]!.isNotEmpty;

    if (isNode || !alreadyExists) {
      components[type]!.add(component);
      
    }
    notifyListeners();
  }

  void removeComponent(Type componentType) {
    components.remove(componentType);
    notifyListeners();
  }

  void update(Duration dt) {
    getComponent<ColliderComponent>()?.update(dt, activeEntity: this);
    getComponent<RigidBodyComponent>()?.update(dt, activeEntity: this);
    components.forEach((type, list) {
      if (type == RigidBodyComponent || type == ColliderComponent) return;
      for (final component in list) {
        component.update(dt, activeEntity: this);
      }
    });
  }

  void teleport({double? dx, double? dy}) {
    position = ui.Offset(dx ?? position.dx, dy ?? position.dy);
    notifyListeners();
  }

  void reset() {
    components.forEach((type, list) {
      for (final component in list) {
        component.reset();
      }
    });
  }

  T? getComponent<T extends Component>() {
    final components = this.components[T];
    if (components == null) return null;
    log('${components.runtimeType}');
    if (components.runtimeType == List<Component>) return (components[0] as T);
    return null;
  }

  List<Component>? getAllComponents<T extends Component>() {
    final components = this.components[T];
    if (components.runtimeType == List<Component>) return components;
    return null;
  }

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void move({double? x, double? y}) {
    position += ui.Offset(x ?? 0, y ?? 0);
    notifyListeners();
  }

  void rotate(double angle) {
    rotation = angle;
    notifyListeners();
  }

  void changeWidth(double width) {
    this.width = width;
    notifyListeners();
  }

  void changeHeight(double height) {
    this.height = height;
    notifyListeners();
  }

  void scaleWidth(double scale) {
    widthScale = scale;
    notifyListeners();
  }

  void scaleHeight(double scale) {
    heigthScale = scale;
    notifyListeners();
  }

  void setWidth(double width){
    this.width = width;
    notifyListeners();
  }

  void setHeight(double height){
    this.height = height;
    notifyListeners();
  }

  void addVariable({required String name, required dynamic value}) {
    variables[name] = value;
    notifyListeners();
  }

  void setVariableXToValueY(String name, dynamic value) {
    variables[name] = value;
    notifyListeners();
  }

  void removeVariable(String name) {
    variables.remove(name);
    notifyListeners();
  }

  void toggleComponent(Type componentType, int index) {
    if (components.containsKey(componentType)) {
      components[componentType]?[index].toggleComponent();
    }
    notifyListeners();
  }

  void setLayerNumber(int newLayerNumber) {
    layerNumber = newLayerNumber;
    notifyListeners();
  }

  void addList(String name, [List<dynamic>? initial = const []]) {
  lists[name] = [...initial!];
  notifyListeners();
}

void addToList(String name, dynamic value) {
  lists[name]?.add(value);
  notifyListeners();
}

void removeFromListAt(String name, int index) {
  lists[name]?.removeAt(index);
  notifyListeners();
}

void insertToListAt(String name, int index, dynamic value) {
  lists[name]?.insert(index, value);
  notifyListeners();
}

}

class OffsetConverter
    implements JsonConverter<ui.Offset, Map<String, dynamic>> {
  const OffsetConverter();

  @override
  ui.Offset fromJson(Map<String, dynamic> json) {
    return ui.Offset(json['x'], json['y']);
  }

  @override
  Map<String, dynamic> toJson(ui.Offset offset) {
    return {
      'x': offset.dx,
      'y': offset.dy,
    };
  }

  
}
