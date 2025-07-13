import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/node_feature/data/output_nodes/branch_node.dart';

class BranchNodeWidget extends StatelessWidget {
  final BranchNode node;

  const BranchNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.deepPurple.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Node UI
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                "Branch Node",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Connection Points
          for (final point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
