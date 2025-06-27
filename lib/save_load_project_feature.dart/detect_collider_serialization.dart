import 'package:scratch_clone/node_feature/data/physics_related_nodes/collision_detection_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension DetectCollisionNodeSerialization on DetectCollisionNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'DetectCollisionNode',
      'entity1Name': entity1Name,
      'entity2Name': entity2Name,
      'hasError': hasError,
    });

  static DetectCollisionNode fromJson(Map<String, dynamic> json) => DetectCollisionNode(
        entity1Name: json['entity1Name'],
        entity2Name: json['entity2Name'],
        hasError: json['hasError'],
        position: OffsetJson.fromJson(json['position']),
      );
}