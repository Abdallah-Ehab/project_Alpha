import 'dart:ui';

import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension SpawnEntityNodeSerialization on SpawnEntityNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'SpawnEntityNode',
      'prefabName': prefabName,
    });

  static SpawnEntityNode fromJson(Map<String, dynamic> json) => SpawnEntityNode(
        prefabName: json['prefabName'] as String,
        position: OffsetJson.fromJson(json['position']),
      );
}