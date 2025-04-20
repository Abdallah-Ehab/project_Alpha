import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';

class ColliderCardWidget extends StatelessWidget {
  const ColliderCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, value, child) {
        final entity = value.activeEntity;
        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
              builder: (BuildContext context, Entity value, Widget? child) {
            ColliderComponent? colliderComponent =
                value.getComponent<ColliderComponent>();
            if (colliderComponent != null) {
              return ChangeNotifierProvider.value(
                value: colliderComponent,
                child: Consumer<ColliderComponent>(
                  builder: (context, ColliderComponent colliderComponent, child) {
                    return Card(
                      elevation: 2.0,
                      child: Column(
                        children: [
                          const Text("Collider Properties"),
                          const SizedBox(height: 10),
                          Text("width"),
                          Slider(
                          value: colliderComponent.width,
                          min: 0,
                          max: 100,
                          divisions: 10,
                          onChanged: (value){
                            colliderComponent.setWidth(value);
                          }),
                          const SizedBox(height: 10),
                          Text("height"),
                          Slider(
                          value: colliderComponent.height,
                          min: 0,
                          max: 100,
                          divisions: 10,
                          onChanged: (value){
                            colliderComponent.setHeight(value);
                          }),
                          // Add more properties and controls for the collider component here
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text("No collider component"));
            }
          }),
        );
      },
    );
  }
}
