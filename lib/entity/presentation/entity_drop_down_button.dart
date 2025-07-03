import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class EntitySelectorDropdown extends StatefulWidget {
  const EntitySelectorDropdown({super.key});

  @override
  State<EntitySelectorDropdown> createState() => _EntitySelectorDropdownState();
}

class _EntitySelectorDropdownState extends State<EntitySelectorDropdown> {
  @override
  Widget build(BuildContext context) {
    final entityManager = context.watch<EntityManager>();
    final allEntities = entityManager.entities.values
        .expand((map) => map.values)
        .toList();
    final activeEntity = entityManager.activeEntity;

    return DropdownButton<String>(
      value: activeEntity.name,
      dropdownColor: Colors.black,
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      items: allEntities.map((entity) {
        return DropdownMenuItem<String>(
          value: entity.name,
          child: Text(entity.name, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? selected) {
        if (selected != null) {
          entityManager.setActiveEntityByName(selected);
        }
      },
    );
  }
}
