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
}