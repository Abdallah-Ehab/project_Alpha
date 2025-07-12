import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_node_with_value.dart';

class MoveNodeValueBasedWidget extends StatelessWidget {
  final MoveNodeValueBased nodeModel;

  const MoveNodeValueBasedWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: nodeModel.width,
      height: nodeModel.height,
      decoration: BoxDecoration(
        color: nodeModel.color,
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: const [
                Text("Move (Value-Based)", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("← dx   dy →", style: TextStyle(fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          for (var point in nodeModel.connectionPoints) point.build(context),
        ],
      ),
    );
  }
}
