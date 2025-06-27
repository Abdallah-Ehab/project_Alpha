import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

class NodeIconWidget extends StatelessWidget {
  final NodeModel nodeModel; // Or a factory/lambda to create the node
  final String label;

  const NodeIconWidget({
    super.key,
    required this.nodeModel,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<NodeModel>(
      data: nodeModel,
      feedback: Material(
        child: Container(
          width: 50,
          height: 50,
          color: nodeModel.color.withAlpha(200),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
      child: Container(
        width: 50,
        height: 50,
        color: nodeModel.color,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ),
    );
  }
}