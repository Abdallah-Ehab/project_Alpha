import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/internal_condition_node.dart';


class ConditionGroupNodeWidget extends StatelessWidget {
  final ConditionGroupNode node;

  const ConditionGroupNodeWidget({super.key, required this.node});

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
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Condition Group",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: node.logicSequence.length,
              itemBuilder: (context, index) {
                final item = node.logicSequence[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: item.buildNode(), // Can be more advanced
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showAddConditionDialog(context);
                },
                child: const Text("Add Condition"),
              ),
              ElevatedButton(
                onPressed: () {
                  _addLogicalOperator(context);
                },
                child: const Text("Add Operator"),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Output connection point
          Align(
            alignment: Alignment.bottomRight,
            child: OutputConnectionPoint(
              position: const Offset(0, 0), // dummy offset
              width: 16,
            ).build(context, node),
          ),
        ],
      ),
    );
  }

  void _showAddConditionDialog(BuildContext context) {
    // Show a dialog with two TextFields and a DropdownButton
    showDialog(
      context: context,
      builder: (context) {
        final leftController = TextEditingController();
        final rightController = TextEditingController();
        String selectedOperator = '==';
        final operators = ['==', '!=', '<', '>', '<=', '>='];

        return AlertDialog(
          title: const Text("New Condition"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: leftController, decoration: const InputDecoration(labelText: "Left value")),
              DropdownButtonFormField<String>(
                value: selectedOperator,
                onChanged: (val) => selectedOperator = val!,
                items: operators
                    .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                    .toList(),
              ),
              TextField(controller: rightController, decoration: const InputDecoration(labelText: "Right value")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final newNode = InternalConditionNode(
                  firstOperand: leftController.text,
                  comparisonOperator: selectedOperator,
                  secondOperand: rightController.text, color: Colors.green,width: 100,height:100
                );
                node.addLogicNode(newNode);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addLogicalOperator(BuildContext context) {
    // You can customize this to allow AND/OR selection
    final operatorNode = LogicOperatorNode(operator: LogicalOperator.and, color: Colors.red, width: 100, height: 100);
    node.addLogicNode(operatorNode);
  }
}
