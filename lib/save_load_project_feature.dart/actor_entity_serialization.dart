import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/actor_entity.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension ActorEntitySerialization on ActorEntity {
  Map<String, dynamic> toJson() => {
        'type': 'ActorEntity',
        'name': name,
        'position': position.toJson(),
        'rotation': rotation,
        'width': width,
        'height': height,
        'widthScale': widthScale,
        'heigthScale': heigthScale,
        'layerNumber': layerNumber,
        'variables': variables,
        'components': components.map((key, component) =>
            MapEntry(key.toString(), component.toJson())),
        'children': children.map((child) {
          if (child is ActorEntity) return child.toJson();
          throw UnimplementedError('Unknown child entity type');
        }).toList(),
      };

  static ActorEntity fromJson(Map<String, dynamic> json) {
    final entity = ActorEntity(
      name: json['name'] as String,
      position: OffsetJson.fromJson(json['position']),
      rotation: (json['rotation'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      layerNumber: json['layerNumber'] as int,
    );

    entity.widthScale = (json['widthScale'] as num).toDouble();
    entity.heigthScale = (json['heigthScale'] as num).toDouble();
    entity.variables = Map<String, dynamic>.from(json['variables']);

    final componentMap = json['components'] as Map<String, dynamic>;
    for (final entry in componentMap.entries) {
      switch (entry.key) {
        case 'NodeComponent':
          entity.components[NodeComponent] = NodeComponent.fromJson(entry.value);
          break;
        case 'AnimationControllerComponent':
          entity.components[AnimationControllerComponent] =
              AnimationControllerComponent.fromJson(entry.value);
          break;
        // Add other component cases here as needed
        default:
          throw UnimplementedError('Unknown component type: ${entry.key}');
      }
    }

    final childrenJson = json['children'] as List<dynamic>;
    entity.children = childrenJson.map((e) => ActorEntity.fromJson(e)).toList();

    return entity;
  }
}
