import 'package:flutter/material.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node.dart';

class SpawnEntityNodeWidget extends StatelessWidget {
  final SpawnEntityNode node;

  const SpawnEntityNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      child: Column(
        children: [
          const Text("Prefab Name:"),
          TextField(
            controller: TextEditingController(text: node.prefabName),
            onChanged: (val) => node.setPrefabName(val),
            decoration: const InputDecoration(
              hintText: "Enter prefab name",
            ),
          ),
        ],
      ),
    );
  }
}
