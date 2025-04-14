import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/presentation/control_panel.dart';
import 'package:scratch_clone/entity/presentation/entity_renderer.dart';

class GameScene extends StatelessWidget {
  const GameScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Game Scene Preview
        Consumer<EntityManager>(
          builder: (context, entityManager, child) => Container(
            color: Colors.blue.shade100,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: entityManager.entities.values.map((entity) {
                return ChangeNotifierProvider.value(
                  value: entity,
                  child: Consumer<Entity>(

                    builder: (context, value, child) =>  Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(entity.position.dx, entity.position.dy)
                        ..rotateZ(entity.rotation)
                        ..scale(entity.scale, entity.scale, entity.scale),
                      child: GestureDetector(
                        onTap: () {
                          entityManager.activeEntity = entity;
                        },
                        child: EntityRenderer(entity: entity),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Control Panel
        const Expanded(child: ControlPanel()),
      ],
    );
  }
}