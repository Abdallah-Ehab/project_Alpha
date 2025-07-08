import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/simple_teleport_node.dart';

class SimpleTeleportNodeWidget extends StatelessWidget {
  final SimpleTeleportNode nodeModel;

  const SimpleTeleportNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    final xController = TextEditingController(text: nodeModel.dx.toString());
    final yController = TextEditingController(text: nodeModel.dy.toString());

    return Container(
      width: nodeModel.width,
      height: nodeModel.height,
      decoration: BoxDecoration(
        color: nodeModel.color,
        border: Border.all(color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text("Simple Teleport", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("X: "),
                    Expanded(
                      child: TextField(
                        controller: xController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) nodeModel.setX(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text("Y: "),
                    Expanded(
                      child: TextField(
                        controller: yController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) nodeModel.setY(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          for (var point in nodeModel.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
