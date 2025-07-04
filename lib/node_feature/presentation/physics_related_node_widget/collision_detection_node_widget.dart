import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/physics_related_nodes/collision_detection_node.dart';

class DetectCollisionNodeWidget extends StatelessWidget {
  final DetectCollisionNode nodeModel;

  const DetectCollisionNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEntityDialog(context),
      child: Stack(
        children: [
          Container(
            width: nodeModel.width,
            height: nodeModel.height,
            decoration: BoxDecoration(
              color: nodeModel.hasError ? Colors.red : nodeModel.color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Center(
              child: Text(
                "Collision\n${nodeModel.entity1Name} ↔ ${nodeModel.entity2Name}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ...nodeModel.connectionPoints.map((cp) => cp.build(context)),
        ],
      ),
    );
  }

  void _showEntityDialog(BuildContext context) {
    final entity1Controller = TextEditingController(text: nodeModel.entity1Name);
    final entity2Controller = TextEditingController(text: nodeModel.entity2Name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Entities to Check Collision"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: entity1Controller,
              decoration: const InputDecoration(labelText: "Entity 1 Name"),
            ),
            TextField(
              controller: entity2Controller,
              decoration: const InputDecoration(labelText: "Entity 2 Name"),
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
              nodeModel.setEntities(
                entity1Controller.text.trim(),
                entity2Controller.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
