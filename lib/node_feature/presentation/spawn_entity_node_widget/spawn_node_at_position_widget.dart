import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/connection_point_model.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/spawn_node_at_position.dart';

class SpawnAtNodeWidget extends StatelessWidget {
  final SpawnAtNode node;

  const SpawnAtNodeWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final prefabs = context.watch<EntityManager>().prefabs;
    final xController = TextEditingController(text: node.x.toString());
    final yController = TextEditingController(text: node.y.toString());

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
              const Text("Spawn At", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 4),

              // Dropdown for prefab selection
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
                    node.prefabName = value;
                  }
                },
              ),

              const SizedBox(height: 8),

              // X field (only shown if no value connection)
              if ((node.connectionPoints[2] as ValueConnectionPoint).sourcePoint == null)
                Row(
                  children: [
                    const Text("X: ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: xController,
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) node.x = parsed;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ),
                  ],
                ),

              if ((node.connectionPoints[3] as ValueConnectionPoint).sourcePoint == null)
                Row(
                  children: [
                    const Text("Y: ", style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: yController,
                        onSubmitted: (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null) node.y = parsed;
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

        // Connection points (flow + value)
        for (var cp in node.connectionPoints) cp.build(context),
      ],
    );
  }
}
