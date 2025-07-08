import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/simple_rotation_node.dart';

class SimpleRotationNodeWidget extends StatelessWidget {
  final SetRotationNode nodeModel;

  const SimpleRotationNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: nodeModel.rotation.toString());

    return Container(
      width: nodeModel.width,
      height: nodeModel.height,
      decoration: BoxDecoration(
        color: nodeModel.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  "Rotate:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                      border: OutlineInputBorder(),
                      hintText: '0.0',
                      hintStyle: TextStyle(color: Colors.white60),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) {
                        nodeModel.rotation = parsed;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Render connection points
          ...nodeModel.connectionPoints.map((cp) => cp.build(context)),
        ],
      ),
    );
  }
}
