import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/teleport_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension TeleportNodeSerialization on TeleportNode {
  Map<String, dynamic> toJson() => baseToJson()..addAll({'type': 'TeleportNode'});

  static TeleportNode fromJson(Map<String, dynamic> json) => TeleportNode(
        position: OffsetJson.fromJson(json['position']),
      );
}
