import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node.dart';

class SpawnEntityNodeWidget extends StatelessWidget {
  final SpawnEntityNode node;

  const SpawnEntityNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final prefabs = context.watch<EntityManager>().prefabs;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Spawn Entity", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              DropdownButton<String>(
                value: prefabs.containsKey(node.prefabName) ? node.prefabName : null,
                dropdownColor: Colors.black,
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                hint: const Text("Select prefab", style: TextStyle(color: Colors.white)),
                items: prefabs.keys.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    node.setPrefabName(value);
                  }
                },
              ),
            ],
          ),
        ),

        // Render connection points
        for (final cp in node.connectionPoints) cp.build(context, node),
      ],
    );
  }
}
