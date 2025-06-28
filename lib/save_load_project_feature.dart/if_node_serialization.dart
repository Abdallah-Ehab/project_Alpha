import 'dart:ui';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';
import 'package:scratch_clone/save_load_project_feature.dart/json_helpers.dart';

extension IfNodeSerialization on IfNode {
  Map<String, dynamic> toJson() => baseToJson()
    ..addAll({'type': 'IfNode'});

  static IfNode fromJson(Map<String, dynamic> json) {
    return IfNode(
      position: OffsetJson.fromJson(json['position']),
      
    )..id = json['id']; // preserve id for linking
  }
}
