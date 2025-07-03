
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';

extension MoveNodeSerialization on MoveNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({
      'type': 'MoveNode',
      'x': x,
      'y': y,
    });

  static MoveNode fromJson(Map<String, dynamic> json) => MoveNode(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}