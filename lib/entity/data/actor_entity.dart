import 'dart:ui';

import 'package:scratch_clone/entity/data/entity.dart';

class ActorEntity extends Entity{
  List<Entity> children;
  ActorEntity({
    required super.name,
    required super.position,
    required super.rotation,
    super.width,
    super.height,
    super.layerNumber,
    this.children = const [],
  });

  factory ActorEntity.fromJson(Map<String, dynamic> json) {
    return ActorEntity(
      name: json['name'] as String,
      position: Entity.offsetFromJson(json['position'] as Map<String, dynamic>),
      rotation: (json['rotation'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 100,
      height: (json['height'] as num?)?.toDouble() ?? 100,
      layerNumber: json['layerNumber'] as int? ?? 0,
      children: (json['children'] as List<dynamic>?)
          ?.map((childJson) => Entity.fromJson(childJson as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'actor',
      'name': name,
      'position': Entity.offsetToJson(position),
      'rotation': rotation,
      'width': width,
      'height': height,
      'layerNumber': layerNumber,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  void addChild(Entity child) {
    children.add(child);
    notifyListeners();
  }

  @override
  void move({double? x , double? y}){
    position += Offset(x ?? 0, y ?? 0);
    for(var child in children){
      child.move(x: x, y: y);
    }
    notifyListeners();
  }
  
  @override
  @override
ActorEntity copy() {
  final copied = ActorEntity(
    name: name,
    position: position,
    rotation: rotation,
    width: width,
    height: height,
    layerNumber: layerNumber,
    children: children.map((child) => child.copy()).toList(),
  );

  copied.widthScale = widthScale;
  copied.heigthScale = heigthScale;

  // Deep copy components
  copied.components = {
    for (final entry in components.entries)
      entry.key: entry.value.copy(),
  };

  // Copy variables — assuming all values are primitives or immutable
  copied.variables = Map<String, dynamic>.from(variables);

  return copied;
}

}