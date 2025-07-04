import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/simple_condition_node.dart';

class SimpleConditionNodeWidget extends StatelessWidget {
  final SimpleConditionNode node;

  const SimpleConditionNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Stack(
        children: [
          // Output connection point
          ...node.connectionPoints.map((point) => point.build(context)),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Condition"),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _openConditionDialog(context),
                  child: const Text("Set Condition"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openConditionDialog(BuildContext context) {
    final firstController = TextEditingController(text: node.firstOperand?.toString() ?? "");
    final secondController = TextEditingController(text: node.secondOperand?.toString() ?? "");
    String selectedOperator = node.comparisonOperator ?? "==";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Condition"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstController,
              decoration: const InputDecoration(labelText: "First Operand"),
            ),
            DropdownButton<String>(
              value: selectedOperator,
              items: const [
                DropdownMenuItem(value: "==", child: Text("==")),
                DropdownMenuItem(value: ">", child: Text(">")),
                DropdownMenuItem(value: "<", child: Text("<")),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedOperator = value;
                }
              },
            ),
            TextField(
              controller: secondController,
              decoration: const InputDecoration(labelText: "Second Operand"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              node.setFirstOperand(firstController.text.trim());
              node.setSecondOperand(secondController.text.trim());
              node.setOperator(selectedOperator);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
