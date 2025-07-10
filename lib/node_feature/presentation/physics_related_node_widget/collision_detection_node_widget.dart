import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/physics_related_nodes/collision_detection_node.dart';

class DetectCollisionNodeWidget extends StatelessWidget {
  final DetectCollisionNode nodeModel;

  const DetectCollisionNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTagDialog(context),
      child: Stack(
        clipBehavior: Clip.none,
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
                "Collision with Tag\n'${nodeModel.tag}'",
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

  void _showTagDialog(BuildContext context) {
    final tagController = TextEditingController(text: nodeModel.tag);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Tag to Detect Collision"),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(labelText: "Tag (e.g. 'enemy')"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              nodeModel.setTag(tagController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
