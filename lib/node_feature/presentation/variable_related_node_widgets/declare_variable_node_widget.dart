import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/variable_related_nodes/declare_variable_node.dart';

class DeclareVarableNodeWidget extends StatefulWidget {
  final DeclareVariableNode node;

  const DeclareVarableNodeWidget({super.key, required this.node});

  @override
  State<DeclareVarableNodeWidget> createState() => _DeclareVarableNodeWidget();
}

class _DeclareVarableNodeWidget extends State<DeclareVarableNodeWidget> {
  late TextEditingController nameController;
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.node.variableName);
    valueController = TextEditingController(text: widget.node.value.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
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
                  const Text("Set Variable",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "var",
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      SizedBox(
                        width: 75,
                        height: 50,
                        child: TextField(
                          controller: valueController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "val",
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Consumer<Entity>(
              builder: (context, entity, child) =>  IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.white),
                onPressed: (){_confirmVariableDeclaration(context,entity);},
                tooltip: "Create Variable",
              ),
            ),
          ),
          for (final cp in widget.node.connectionPoints)
            cp.build(context, widget.node),
        ],
      ),
    );
  }

  void _confirmVariableDeclaration(BuildContext context, Entity entity) {
    final String name = nameController.text.trim();
    final String value = valueController.text.trim();
    
    // Basic validation
    if (name.isEmpty) {
      _showErrorDialog(context, "Variable name cannot be empty");
      return;
    }
    
    if (value.isEmpty) {
      _showErrorDialog(context, "Variable value cannot be empty");
      return;
    }
    
    // Check if variable already exists
    if (entity.variables.containsKey(name)) {
      _showErrorDialog(
        context, 
        "Variable '$name' already exists. Use a different name.",
        showOverwriteOption: true,
        onOverwrite: () {
          // Parse the value
          final dynamic parsedValue = _parseValue(value);
          // Update the variable
          entity.addVariable(name: name, value: parsedValue);
          Navigator.of(context).pop(); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Variable '$name' updated successfully"))
          );
        }
      );
      return;
    }
    
    // Parse the value
    final dynamic parsedValue = _parseValue(value);
    
    // Add the variable to the entity
    entity.addVariable(name: name, value: parsedValue);
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Variable '$name' declared successfully"))
    );
  }

  dynamic _parseValue(String value) {
    // Try parsing as number
    final double? numValue = double.tryParse(value);
    if (numValue != null) {
      return numValue;
    }
    
    // Check for boolean
    if (value.toLowerCase() == 'true') {
      return true;
    }
    if (value.toLowerCase() == 'false') {
      return false;
    }
    
    return value;
  }
  
  void _showErrorDialog(BuildContext context, String message, {
    bool showOverwriteOption = false,
    VoidCallback? onOverwrite,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Variable Declaration Error"),
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
