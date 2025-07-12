import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/flip_node.dart';

class SimpleFlipNodeWidget extends StatelessWidget {
  final SimpleFlipNode node;

  const SimpleFlipNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Node content
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Simple Flip Node",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: node.flipX,
                      onChanged: (value) {
                        node.setFlipX(value ?? false);
                      },
                    ),
                    const Text("Flip X"),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: node.flipY,
                      onChanged: (value) {
                        node.setFlipY(value ?? false);
                      },
                    ),
                    const Text("Flip Y"),
                  ],
                ),
              ],
            ),
          ),

          // Connection points
          for (var point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
