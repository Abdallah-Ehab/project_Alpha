import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/component/component.dart';

class Entity with ChangeNotifier {
  String name;
  ui.Offset position;
  double rotation;
  double scale;
  Map<Type, Component> components = {};
  Map<String,dynamic> variables = {};
  Entity({
    required this.name,
    required this.position,
    required this.rotation,
    required this.scale,
  });

  void addComponent(Component component) {
    components[component.runtimeType] = component;
    notifyListeners();
  }

  void removeComponent(Type componentType) {
    components.remove(componentType);
    notifyListeners();
  }

  void update(Duration dt) {
    components.forEach((type, component) {
      component.update(dt, activeEntity: this);
    });
  }

  T? getComponent<T extends Component>() {
    final component = components[T];
    if (component is T) return component;
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

  void scaleEntity(double scale){
    this.scale = scale;
    notifyListeners();
  }

  void addVariable({required String name, required dynamic value}){
    variables[name] = value;
    notifyListeners();
  }

  void setVariableXToValueY(String name, dynamic value){
    variables[name] = value;
    notifyListeners();
  }

  void removeVariable(String name){
    variables.remove(name);
    notifyListeners();
  }

  void toggleComponent(Type componentType){
    if(components.containsKey(componentType)){
      components[componentType]!.toggleComponent();
    }
    notifyListeners();
  }

}
