
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class AnimationTransitionPage extends StatelessWidget {
  const AnimationTransitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EntityManager>(
        builder: (context, entityManager, child) {
          final entity = entityManager.activeEntity;
          return ChangeNotifierProvider.value(
            value: entity,
            child: Consumer<Entity>(
              builder: (context, entity, child) {
                final animationComponent = entity.getComponent<AnimationControllerComponent>();
                return ChangeNotifierProvider.value(
                  value: animationComponent,
                  child: Consumer<AnimationControllerComponent>(
                    builder: (context, animComponent, child) {
                      return Stack(
                        children: animComponent.animationTracks.values.map((track) {
                          return Positioned(
                            left: track.trackPosition.dx,
                            top: track.trackPosition.dy,
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.red,
                              child: Center(child: Text(track.name,style: TextStyle(color: Colors.white),)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
