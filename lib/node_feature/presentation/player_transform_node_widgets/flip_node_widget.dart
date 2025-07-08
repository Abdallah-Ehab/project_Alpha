import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/flip_node.dart';

class FlipNodeWidget extends StatelessWidget {
  final FlipNode nodeModel;

  const FlipNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Flip Entity",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Takes two boolean values via connection points:\n• Flip X\n• Flip Y",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
          ...nodeModel.connectionPoints.map((cp) => cp.build(context)),
        ],
      ),
    );
  }
}
