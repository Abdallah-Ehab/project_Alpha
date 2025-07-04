import 'package:flutter/material.dart';

import 'package:scratch_clone/node_feature/data/flow_control_nodes/if_node.dart';


class IfNodeWidget extends StatelessWidget {
  final IfNode nodeModel;

  const IfNodeWidget({super.key, required this.nodeModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Node Container
        Container(
          width: nodeModel.width,
          height: nodeModel.height,
          decoration: BoxDecoration(
            color: nodeModel.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: const Center(
            child: Material(
              color: Colors.transparent,
              child: Text(
                "If",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Connection Points
        ...nodeModel.connectionPoints.map((point) {
          return point.build(context);
        }),
      ],
    );
  }

}
