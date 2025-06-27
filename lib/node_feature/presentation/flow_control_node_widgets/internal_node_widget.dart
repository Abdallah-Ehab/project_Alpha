import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/internal_condition_node.dart';

class InternalConditionNodeWidget extends StatelessWidget {
  final InternalConditionNode node;

  const InternalConditionNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: Text(
        node.toString(),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
