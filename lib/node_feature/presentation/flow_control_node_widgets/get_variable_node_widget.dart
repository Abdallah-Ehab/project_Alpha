import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/get_variable_node.dart';

class GetVariableNodeWidget extends StatefulWidget {
  final GetVariableNode node;

  const GetVariableNodeWidget({super.key, required this.node});

  @override
  State<GetVariableNodeWidget> createState() => _GetVariableNodeWidgetState();
}

class _GetVariableNodeWidgetState extends State<GetVariableNodeWidget> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.node.variableName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.node.width,
      height: widget.node.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: widget.node.color,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text(
                    "Get Variable",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text("var: ", style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (val) {
                            widget.node.setVariableName(val.trim());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Connection points (input and output)
          for (final cp in widget.node.connectionPoints)
            cp.build(context),
        ],
      ),
    );
  }
}
