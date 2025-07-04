import 'package:flutter/material.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/node_feature/data/object_property_nodes/get_property_node.dart';
import 'package:scratch_clone/node_feature/presentation/connection_point_widget.dart';

class GetPropertyFromEntityNodeWidget extends StatelessWidget {
  final GetPropertyFromEntityNode nodeModel;

  const GetPropertyFromEntityNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Container
        GestureDetector(
          onTap: () => _showEntityPropertyDialog(context),
          child: Container(
            width: nodeModel.width,
            height: nodeModel.height,
            decoration: BoxDecoration(
              color: nodeModel.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: const Center(
              child: Text(
                "Get Property\n(Tap to Edit)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Output Connection Points (1 or 2 based on property type)
        ..._buildConnectionPoints(context),
      ],
    );
  }

  void _showEntityPropertyDialog(BuildContext context) {
    final entityController = TextEditingController(text: nodeModel.entityName);
    Property selected = nodeModel.selectedProperty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Configure Get Property Node"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: entityController,
              decoration: const InputDecoration(labelText: "Entity Name"),
            ),
            const SizedBox(height: 8),
            DropdownButton<Property>(
              value: selected,
              onChanged: (prop) {
                if (prop != null) {
                  selected = prop;
                }
              },
              items: Property.values.map((prop) {
                return DropdownMenuItem(
                  value: prop,
                  child: Text(prop.name),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              nodeModel.setEntityName(entityController.text);
              nodeModel.setProperty(selected);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConnectionPoints(BuildContext context) {
    if (nodeModel.hasTwoOutputs) {
      return [
        for(final cp in nodeModel.connectionPoints)
        cp.build(context)
      ];
    } else {
      return [
       nodeModel.connectionPoints[0].build(context)
       ,nodeModel.connectionPoints[1].build(context)
      ];
    }
  }
}
