import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';

abstract class Entity with ChangeNotifier {
  String name;
  ui.Offset position;
  double rotation;
  double width;
  double height;
  double widthScale = 1.0; 
  double heigthScale = 1.0;
  Map<Type, Component> components = {};
  Map<String,dynamic> variables = {};
  int layerNumber;
  Entity({
    required this.name,
    required this.position,
    required this.rotation,
    this.width = 100,
    this.height = 100,
    this.layerNumber = 0
  });

  void addComponent(Component component) {
    if(component is ColliderComponent){
      component.position = position;
      component.width = width;
      component.height = height;
    }
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
  void reset(){
    components.forEach((type, component) {
      component.reset();
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

  void changeWidth(double width){
    this.width = width;
    notifyListeners();
  }

  void changeHeight(double height){
    this.height = height;
    notifyListeners();
  }

  void scaleWidth(double scale){
    widthScale = scale;
    notifyListeners();
  }

  void scaleHeight(double scale){
    heigthScale = scale;
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
  void setLayerNumber(int newLayerNumber){
    layerNumber = newLayerNumber;
    notifyListeners();
  }

}
