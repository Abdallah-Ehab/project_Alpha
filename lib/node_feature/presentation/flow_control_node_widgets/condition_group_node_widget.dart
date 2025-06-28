import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/condition_group_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logic_element.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/logical_operator_node.dart';
import 'package:scratch_clone/node_feature/data/flow_control_nodes/internal_condition_node.dart';


class ConditionGroupNodeWidget extends StatefulWidget {
  final ConditionGroupNode node;

  const ConditionGroupNodeWidget({super.key, required this.node});

  @override
  State<ConditionGroupNodeWidget> createState() => _ConditionGroupNodeWidgetState();
}

class _ConditionGroupNodeWidgetState extends State<ConditionGroupNodeWidget> {
  double baseHeight = 180;
  double perNodeHeight = 60;

  double calculateHeight() {
    final logicCount = widget.node.logicSequence.length;
    return baseHeight + (logicCount * perNodeHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.node.width,
      height: calculateHeight(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.node.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Text(
                      "Condition Group",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.node.logicSequence.isEmpty)
                    const Text("No conditions yet"),
                  ...widget.node.logicSequence.map((logicNode) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: logicNode.buildNode(),
                      )),
                  const Divider(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => _showAddConditionDialog(context),
                          child: const Text("Add Condition"),
                        ),
                        ElevatedButton(
                          onPressed: () => _showAddOperatorDialog(context),
                          child: const Text("Add Operator"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final cp in widget.node.connectionPoints)
            cp.build(context, widget.node),
        ],
      ),
    );
  }

  void _showAddConditionDialog(BuildContext context) {
    final leftController = TextEditingController();
    final rightController = TextEditingController();
    String selectedOperator = '==';
    final operators = ['==', '!=', '<', '>', '<=', '>='];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Condition"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: leftController, decoration: const InputDecoration(labelText: "Left value")),
                DropdownButtonFormField<String>(
                  value: selectedOperator,
                  onChanged: (val) => selectedOperator = val!,
                  items: operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                ),
                TextField(controller: rightController, decoration: const InputDecoration(labelText: "Right value")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final newNode = InternalConditionNode(
                  firstOperand: leftController.text,
                  comparisonOperator: selectedOperator,
                  secondOperand: rightController.text,
                  color: Colors.green,
                  width: 100,
                  height: 100,
                );
                setState(() {
                  widget.node.addLogicNode(newNode);
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showAddOperatorDialog(BuildContext context) {
    LogicalOperator selected = LogicalOperator.and;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Operator"),
          content: DropdownButtonFormField<LogicalOperator>(
            value: selected,
            onChanged: (op) => selected = op!,
            items: LogicalOperator.values.map((op) {
              return DropdownMenuItem(
                value: op,
                child: Text(op == LogicalOperator.and ? "AND" : "OR"),
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final opNode = LogicOperatorNode(
                  operator: selected,
                  color: Colors.red,
                  width: 100,
                  height: 100,
                );
                setState(() {
                  widget.node.addLogicNode(opNode);
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
