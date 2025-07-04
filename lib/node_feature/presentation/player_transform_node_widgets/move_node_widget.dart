import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node.dart';

class MoveNodeWidget extends StatelessWidget {
  final MoveNode node;

  const MoveNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final xController = TextEditingController(text: node.x.toString());
    final yController = TextEditingController(text: node.y.toString());

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
          // Node UI
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text("Move Node", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("X: "),
                    Expanded(
                      child: TextField(
                        controller: xController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null) node.setX(parsed);
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                    SizedBox(width: 20,),
                    const Text("Y: "),
                    
                Expanded(
                  child: TextField(
                    controller: yController,
                    onSubmitted: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null) node.setY(parsed);
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

          // Connection Points
          for (var point in node.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
