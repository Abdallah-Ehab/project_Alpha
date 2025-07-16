import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_for_node.dart';

class MoveForSecondsNodeWidget extends StatelessWidget {
  final MoveForSecondsNode node;

  const MoveForSecondsNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final dxController = TextEditingController(text: node.dx.toString());
    final dyController = TextEditingController(text: node.dy.toString());
    final durationController = TextEditingController(text: node.duration.toString());

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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text("Move For Seconds", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("dx: "),
                    Expanded(
                      child: TextField(
                        controller: dxController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) node.setDx(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("dy: "),
                    Expanded(
                      child: TextField(
                        controller: dyController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) node.setDy(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text("Duration: "),
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) node.setDuration(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                    const Text("s"),
                  ],
                ),
              ],
            ),
          ),

          // Draw connection points
          for (var point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
