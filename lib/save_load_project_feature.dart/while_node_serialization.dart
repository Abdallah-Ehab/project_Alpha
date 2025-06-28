import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/while_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension WhileNodeSerialization on WhileNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({'type': 'WhileNode'});

  static WhileNode fromJson(Map<String, dynamic> json) => WhileNode(
        position: OffsetJson.fromJson(json['position']),
      );
}
