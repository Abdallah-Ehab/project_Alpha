import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/spawn_node/destroy_node_with_name.dart';

class DestroyEntityNodeWithNameWidget extends StatelessWidget {
  final DestroyEntityNodeWithName node;

  const DestroyEntityNodeWithNameWidget({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final entityNames = context.read<EntityManager>().allEntities
        .map((e) => e.name)
        .where((name) => name.isNotEmpty)
        .toList();

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
              child: Column(
                children: [
                  const Text(
                    "Destroy Entity",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  DropdownButton<String>(
                    dropdownColor: Colors.black87,
                    value: node.entityName.isEmpty
                        ? (entityNames.isNotEmpty ? entityNames.first : null)
                        : node.entityName,
                    items: entityNames.map((name) {
                      return DropdownMenuItem(
                        value: name,
                        child: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        node.setEntityName(value);
                      }
                    },
                  ),
                ],
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
