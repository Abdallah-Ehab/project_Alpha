import 'dart:ui';

import 'package:scratch_clone/node_feature/data/node_model.dart';

abstract class LogicElementNode extends NodeModel {
  LogicElementNode(
      {
        super.position = Offset.zero,
      required super.color,
      required super.width,
      required super.height,
      required super.connectionPoints});
}
