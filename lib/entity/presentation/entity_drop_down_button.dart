import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class EntitySelectorArrows extends StatelessWidget {
  const EntitySelectorArrows({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.watch<EntityManager>();
    final allEntities = entityManager.entities.values
        .expand((map) => map.values)
        .toList();
    final activeEntity = entityManager.activeEntity;

    // find current index
    final currentIndex = allEntities.indexOf(activeEntity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          color: Colors.white,
          onPressed: currentIndex > 0
              ? () {
                  final prev = allEntities[currentIndex - 1];
                  entityManager.setActiveEntityByName(prev.name);
                }
              : null, // disabled at start
        ),
        Text(
          activeEntity.name,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          color: Colors.white,
          onPressed: currentIndex < allEntities.length - 1
              ? () {
                  final next = allEntities[currentIndex + 1];
                  entityManager.setActiveEntityByName(next.name);
                }
              : null, // disabled at end
        ),
      ],
    );
  }
}
