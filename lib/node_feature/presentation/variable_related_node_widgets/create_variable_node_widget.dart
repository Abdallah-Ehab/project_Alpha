import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/create_variable_node.dart';

class CreateVariableNodeWidget extends StatelessWidget {
  final CreateVariableNode node;

  const CreateVariableNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: node.variableName);
    final valueController = TextEditingController(text: node.value.toString());

    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Create Variable", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name", isDense: true),
            onChanged: (val) => node.setVariableName(val),
          ),
          TextField(
            controller: valueController,
            decoration: const InputDecoration(labelText: "Value", isDense: true),
            onChanged: (val) {
              final parsed = double.tryParse(val);
              node.setValue(parsed ?? val); // allow both number & string
            },
          ),
          const Spacer(),
          Align(
            alignment: Alignment.topCenter,
            child: node.connectionPoints
                .firstWhere((c) => c is ConnectConnectionPoint && c.isTop)
                .build(context, node),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: node.connectionPoints
                .firstWhere((c) => c is ConnectConnectionPoint && !c.isTop)
                .build(context, node),
          ),
        ],
      ),
    );
  }
}
