import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
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
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
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
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) node.setX(parsed);
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Y: "),
              Expanded(
                child: TextField(
                  controller: yController,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) node.setY(parsed);
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
            ],
          ),
          // Connection Points
          Align(
            alignment: Alignment.topCenter,
            child: node.connectionPoints
                .firstWhere((p) => p is ConnectConnectionPoint && p.isTop)
                .build(context, node),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: node.connectionPoints
                .firstWhere((p) => p is ConnectConnectionPoint && !p.isTop)
                .build(context, node),
          ),
        ],
      ),
    );
  }
}
