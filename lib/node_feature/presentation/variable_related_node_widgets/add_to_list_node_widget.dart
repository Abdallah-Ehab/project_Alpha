import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/add_to_list_node.dart';

class AddToListNodeWidget extends StatefulWidget {
  final AddToListNode node;

  const AddToListNodeWidget({super.key, required this.node});

  @override
  State<AddToListNodeWidget> createState() => _AddToListNodeWidgetState();
}

class _AddToListNodeWidgetState extends State<AddToListNodeWidget> {
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entity = context.read<Entity>();

    return Container(
      width: widget.node.width,
      height: widget.node.height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text("Add To List", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: "Value",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: widget.node.listName.isNotEmpty ? widget.node.listName : null,
                hint: const Text("List"),
                items: entity.lists.keys.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    widget.node.listName = newValue!;
                  });
                },
              )
            ],
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = _parseValue(valueController.text);
              entity.addToList(widget.node.listName, parsed);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Value added to list")));
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  dynamic _parseValue(String value) {
    final double? numVal = double.tryParse(value);
    if (numVal != null) return numVal;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    return value;
  }
}
