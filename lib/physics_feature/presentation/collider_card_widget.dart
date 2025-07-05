import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_form_field.dart';
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
                    builder: (context, colliderComponent, child) {
                      return Card(
                        color: const Color(0xFF222222),
                        elevation: 2.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Collider Properties",
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),

                              
                              PixelatedTextFormField(
                                label: 'Width',
                                fieldKey: ValueKey('collider_width_${colliderComponent.hashCode}'),
                                initialValue: colliderComponent.width.toStringAsFixed(2),
                                hintText: 'Width',
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null && parsed >= 0) {
                                    colliderComponent.setWidth(parsed);
                                  }
                                },
                              ),

                              const SizedBox(height: 10),
                              
                            
                              PixelatedTextFormField(
                                label: 'Height',
                                fieldKey: ValueKey('collider_height_${colliderComponent.hashCode}'),
                                initialValue: colliderComponent.height.toStringAsFixed(2),
                                hintText: 'Height',
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null && parsed >= 0) {
                                    colliderComponent.setHeight(parsed);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    "No collider component",
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
