import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/incerement_variable_node.dart';

class IncrementVariableNodeWidget extends StatelessWidget {
  final IncrementVariableNode node;

  const IncrementVariableNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: node.variableName);

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  "Increment",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onSubmitted: (value) => node.setVariableName(value),
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Variable name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Render connection points
          for (var point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
