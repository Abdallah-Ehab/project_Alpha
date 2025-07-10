import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class LightEntity extends Entity {
  double intensity;
  Color color;
  double radius;

  LightEntity({
    required super.name,
    super.tag = 'light',
    required super.position,
    super.rotation = 0,
    super.width,
    super.height,
    this.intensity = 1.0,
    this.color = Colors.white,
    this.radius = 200.0,
    super.layerNumber,
    
  });

  @override
  LightEntity copy() {
    return LightEntity(
      name: name,
      tag : tag,
      position: position,
      rotation: rotation,
      width: width,
      height: height,
      intensity: intensity,
      color: color,
      radius: radius,
      layerNumber: layerNumber,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'light',
      'name': name,
      'tag' : tag,
      'position': Entity.offsetToJson(position),
      'rotation': rotation,
      'width': width,
      'height': height,
      'widthScale': widthScale,
      'heightScale': heigthScale,
      'layerNumber': layerNumber,
      'intensity': intensity,
      'color': color.toARGB32(),
      'radius': radius,
    };
  }

  static LightEntity fromJson(Map<String, dynamic> json) {
    return LightEntity(
      name: json['name'],
      tag : json['tag'],
      position: Entity.offsetFromJson(json['position']),
      rotation: json['rotation'],
      width: json['width'],
      height: json['height'],
      intensity: json['intensity'],
      color: Color(json['color']),
      radius: json['radius'],
      layerNumber: json['layerNumber'],
    );
  }

  void setRadius(double radius){
    this.radius = radius;
    notifyListeners();
  }
  void setLightIntensity(double intensity){
    this.intensity = intensity;
    notifyListeners();
  }

  void setSelectedColor(Color color){
    this.color = color;
    notifyListeners();
  }
}
