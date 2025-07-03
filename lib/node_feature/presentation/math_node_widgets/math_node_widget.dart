import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/node_model.dart';

class MathNodeWidget extends StatelessWidget {
  final NodeModel node;
  final String label;

  const MathNodeWidget({super.key, required this.node, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
