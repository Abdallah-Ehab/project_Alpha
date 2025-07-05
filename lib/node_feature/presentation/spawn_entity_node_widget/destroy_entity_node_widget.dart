import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/destroy_entity_node.dart';

class DestroyEntityNodeWidget extends StatelessWidget {
  final DestroyEntityNode node;

  const DestroyEntityNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: node.width,
      height: node.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: node.color,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Center(
                child: Text(
                  "Destroy Entity",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          for (final cp in node.connectionPoints)
            cp.build(context),
        ],
      ),
    );
  }
}
