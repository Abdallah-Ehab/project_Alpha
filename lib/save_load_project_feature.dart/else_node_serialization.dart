import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/else_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension ElseNodeSerialization on ElseNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({'type': 'ElseNode'});

  static ElseNode fromJson(Map<String, dynamic> json) {
    return ElseNode(
      position: OffsetJson.fromJson(json['position']),
      color: Color(json['color']),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    )..id = json['id'];
  }
}