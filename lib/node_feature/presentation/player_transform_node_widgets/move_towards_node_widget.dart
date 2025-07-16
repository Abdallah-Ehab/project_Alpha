import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/player_transform_control_nodes/move_towards_node.dart';

class MoveTowardsNodeWidget extends StatelessWidget {
  final MoveTowardsNode node;

  const MoveTowardsNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final targetXController = TextEditingController(text: node.targetX.toString());
    final targetYController = TextEditingController(text: node.targetY.toString());
    final speedController = TextEditingController(text: node.speed.toString());

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: node.width,
          height: node.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: node.color,
            border: Border.all(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Move Towards", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),

              // Target X field (only shown if no value connection)
              if ((node.connectionPoints[2] as ValueConnectionPoint).sourcePoint == null)
                Row(
                  children: [
                    const Text("X: ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: targetXController,
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) node.setTargetX(parsed);
                        },
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 4),

              // Target Y field (only shown if no value connection)
              if ((node.connectionPoints[3] as ValueConnectionPoint).sourcePoint == null)
                Row(
                  children: [
                    const Text("Y: ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: targetYController,
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) node.setTargetY(parsed);
                        },
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 4),

              // Speed field (only shown if no value connection)
              if ((node.connectionPoints[4] as ValueConnectionPoint).sourcePoint == null)
                Row(
                  children: [
                    const Text("Speed: ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: speedController,
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) node.setSpeed(parsed);
                        },
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.black26,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Connection points (flow + value)
        for (var cp in node.connectionPoints) cp.build(context),
      ],
    );
  }
}