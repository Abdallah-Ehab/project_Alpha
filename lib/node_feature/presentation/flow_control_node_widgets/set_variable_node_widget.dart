import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/set_variable_node.dart';

class SetVariableNodeWidget extends StatefulWidget {
  final SetVariableNode node;

  const SetVariableNodeWidget({super.key, required this.node});

  @override
  State<SetVariableNodeWidget> createState() => _SetVariableNodeWidgetState();
}

class _SetVariableNodeWidgetState extends State<SetVariableNodeWidget> {
  late TextEditingController nameController;
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.node.variableName);
    valueController = TextEditingController(text: widget.node.value.toString());

    widget.node.addListener(_updateUI);
  }

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
    widget.node.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    setState(() {
      // Triggers rebuild when connection state or node state changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final valueInput = widget.node.connectionPoints[2] as ValueConnectionPoint;
    final isValueConnected = valueInput.sourcePoint != null;

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
                    "Set Variable",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "var",
                            isDense: true,
                          ),
                          onChanged: (val) => widget.node.setVariableName(val.trim()),
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (!isValueConnected)
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: valueController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "val",
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final parsed = _parseValue(val.trim());
                              widget.node.setValue(parsed);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          for (final cp in widget.node.connectionPoints) cp.build(context),
        ],
      ),
    );
  }

  dynamic _parseValue(String value) {
    final double? numValue = double.tryParse(value);
    if (numValue != null) return numValue;

    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;

    return value; // fallback to string
  }
}
