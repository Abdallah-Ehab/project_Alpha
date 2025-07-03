import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_list_node.dart';

class DeclareListNodeWidget extends StatefulWidget {
  final DeclareListNode node;

  const DeclareListNodeWidget({super.key, required this.node});

  @override
  State<DeclareListNodeWidget> createState() => _DeclareListNodeWidgetState();
}

class _DeclareListNodeWidgetState extends State<DeclareListNodeWidget> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.node.listName);
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
                  const Text("Declare List",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "List Name",
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Consumer<Entity>(
              builder: (context, entity, child) => IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                tooltip: "Create List",
                onPressed: () {
                  _createList(context, entity);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createList(BuildContext context, Entity entity) {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      _showErrorDialog(context, "List name cannot be empty");
      return;
    }

    if (entity.lists.containsKey(name)) {
      _showErrorDialog(
        context,
        "List '$name' already exists.",
        showOverwriteOption: true,
        onOverwrite: () {
          entity.addList(name); // Overwrite with empty list
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("List '$name' overwritten")));
        },
      );
      return;
    }

    entity.addList(name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("List '$name' declared")),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String message, {
    bool showOverwriteOption = false,
    VoidCallback? onOverwrite,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("List Declaration Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
          if (showOverwriteOption && onOverwrite != null)
            TextButton(
              onPressed: onOverwrite,
              child: const Text("Overwrite"),
            ),
        ],
      ),
    );
  }
}
