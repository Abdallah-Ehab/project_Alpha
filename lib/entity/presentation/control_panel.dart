import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/full_animation_page.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/core/ui_widgets/animation_component.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_form_field.dart';
import 'package:scratch_clone/core/ui_widgets/sound_component_widget.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_card_widget.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';
import 'package:scratch_clone/sound_feature/presentation/full_sound_page.dart';

class ComponentPanels extends StatelessWidget {
  const ComponentPanels({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) { 
        final entity = entityManager.activeEntity;
        if(entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        return ChangeNotifierProvider.value(
        value: entity,
        child: Consumer<Entity>(
          builder: (context, entity, child) {
            
            return SizedBox(
              width: double.infinity,
              child: Card(
                color: const Color(0xffE8E8E8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Components',
                            style: TextStyle(
                                fontFamily: 'PressStart2P', fontSize: 18)),
                        const SizedBox(height: 10),
                        EntityPropertiesPanel(),
                        const SizedBox(height: 10),
                        if (entity.getComponent<AnimationControllerComponent>() !=
                            null)
                          AnimationComponentPanel(),
                        if (entity.getAllComponents<NodeComponent>() != null)
                          NodeComponentPanel(entity: entity,),
                        if (entity.getComponent<ColliderComponent>() != null)
                          const ColliderCardWidget(),
                        if (entity.getComponent<SoundControllerComponent>() != null)
                          SoundComponentPanel(),
                        if (entity.getComponent<RigidBodyComponent>() != null)
                          const RigidBodyComponentPanel(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );}
    );
  }
}

class EntityPropertiesPanel extends StatelessWidget {
  const EntityPropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }

        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) => Card(
              color: const Color(0xFF333333),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entity Properties',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    PixelatedTextFormField(
                      label: 'Name',
                      fieldKey: ValueKey('name_${entity.hashCode}'),
                      initialValue: entity.name,
                      hintText: 'Name',
                      keyboardType: TextInputType.text,
                      onChanged: entity.setName,
                    ),
                    const SizedBox(height: 10),

                    // Position X and Y
                    Row(
                      children: [
                        Expanded(
                          child: PixelatedTextFormField(
                            label: 'pos X',
                            fieldKey: ValueKey('pos_x_${entity.hashCode}'),
                            initialValue: entity.position.dx.toStringAsFixed(2),
                            hintText: 'Position X',
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final dx = double.tryParse(val) ?? entity.position.dx;
                              entity.teleport(dx: dx);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PixelatedTextFormField(
                            label: 'pos Y',
                            fieldKey: ValueKey('pos_y_${entity.hashCode}'),
                            initialValue: entity.position.dy.toStringAsFixed(2),
                            hintText: 'Position Y',
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              final dy = double.tryParse(val) ?? entity.position.dy;
                              entity.teleport(dy: dy);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Rotation
                    PixelatedSlider(
                      label: 'Rotation: ${entity.rotation.toStringAsFixed(0)}°',
                      min: 0,
                      max: 360,
                      divisions: 36,
                      value: entity.rotation,
                      onChanged: entity.rotate,
                    ),
                    const SizedBox(height: 10),

                    // Width Scale
                    PixelatedTextFormField(
                      label: 'Width',
                      fieldKey: ValueKey('width_${entity.hashCode}'),
                      initialValue: entity.width.toStringAsFixed(2),
                      hintText: 'Width',
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final width = double.tryParse(val);
                        if (width != null && width > 0) {
                          entity.setWidth(width);
                          final collider = entity.getComponent<ColliderComponent>();
                          if(collider != null) {
                 
                          collider.setWidth(width);
                        }
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Height Scale
                    PixelatedTextFormField(
                      label: 'Height',
                      fieldKey: ValueKey('height_${entity.hashCode}'),
                      initialValue: entity.heigthScale.toStringAsFixed(2),
                      hintText: 'Height Scale',
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final height = double.tryParse(val);
                        if (height != null && height > 0) {
                          entity.setHeight(height);
                          final collider = entity.getComponent<ColliderComponent>();
                          if(collider != null) {
                            collider.setHeight(height);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class RigidBodyComponentPanel extends StatelessWidget {
  const RigidBodyComponentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        
        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) {
              final comp = entity.getComponent<RigidBodyComponent>();
              if (comp == null) {
                return const Center(
                  child: Text(
                    'No rigid body component found',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return ChangeNotifierProvider.value(
                value: comp,
                child: Consumer<RigidBodyComponent>(
                  builder: (context, comp, child) => Card(
                    color: const Color(0xFF333333),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rigid Body Component',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Component Active Toggle
                          Row(
                            children: [
                              Checkbox(
                                value: comp.isActive,
                                onChanged: (value) => comp.toggleComponent(),
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                side: const BorderSide(
                                    color: Colors.white, width: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Text(
                                'Active',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Mass Control
                          PixelatedTextFormField(
                            label: 'Mass',
                            fieldKey: ValueKey('mass_${comp.hashCode}'),
                            initialValue: comp.mass.toStringAsFixed(2),
                            hintText: 'Mass',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final mass = double.tryParse(value) ?? comp.mass;
                              if (mass > 0) {
                                comp.setMass(mass);
                              }
                            },
                          ),
                          const SizedBox(height: 10),

                          // Gravity Control
                          PixelatedTextFormField(
                            label: 'Gravity',
                            fieldKey: ValueKey('gravity_${comp.hashCode}'),
                            initialValue: comp.gravity.toStringAsFixed(2),
                            hintText: 'Gravity',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final gravity =
                                  double.tryParse(value) ?? comp.gravity;
                              comp.setGravity(gravity);
                            },
                          ),
                          const SizedBox(height: 10),

                          // Velocity Controls
                          Row(
                            children: [
                              Expanded(
                                child: PixelatedTextFormField(
                                  label: 'Resistance',
                                  fieldKey: ValueKey('velocity_x_${comp.hashCode}'),
                                  initialValue: comp.velocity.dx.toStringAsFixed(2),
                                  hintText: 'resistance',
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final resistance =
                                        double.tryParse(value) ?? comp.velocity.dx;
                                    comp.setResistance(resistance);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: PixelatedTextFormField(
                                  label: 'Friction',
                                  fieldKey: ValueKey('velocity_y_${comp.hashCode}'),
                                  initialValue: comp.velocity.dy.toStringAsFixed(2),
                                  hintText: 'Friction',
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final friction =
                                        double.tryParse(value) ?? comp.velocity.dy;
                                    comp.setFriction(friction);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Toggles
                          Row(
                            children: [
                              Checkbox(
                                value: comp.useGravity,
                                onChanged: (value) {
                                  comp.setUseGravity(value ?? comp.useGravity);
                                },
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                side: const BorderSide(
                                    color: Colors.white, width: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Text(
                                'Use Gravity',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Checkbox(
                                value: comp.isStatic,
                                onChanged: (value) {
                                  comp.setIsStatic(value ?? comp.isStatic);
                                },
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                side: const BorderSide(
                                    color: Colors.white, width: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const Text(
                                'Static',
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Status indicators
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color:
                                      comp.isGrounded ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comp.isGrounded ? 'Grounded' : 'Airborne',
                                style: const TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Fall Progress Bar
                          if (!comp.isGrounded && comp.fallProgress > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fall Progress: ${comp.fallProgress.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: (comp.fallProgress / comp.maxFallSpeed)
                                      .clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[800],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.orange),
                                ),
                              ],
                            ),
                          

                          // Force Application Buttons
                          
                          
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AnimationComponentPanel extends StatelessWidget {
  const AnimationComponentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        
        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) {
              final comp = entity.getComponent<AnimationControllerComponent>();
              if (comp == null) {
                return const Center(
                  child: Text(
                    'No animation component found',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return ChangeNotifierProvider.value(
                value: comp,
                child: Consumer<AnimationControllerComponent>(
                  builder: (context, comp, child) => AnimationControllerWidget(
                    options: comp.animationTracks.keys.toList(),
                    initiallyChecked: comp.isActive,
                    initiallySelection: comp.currentAnimationTrack.name,
                    onToggleChecked: (_) => comp.toggleComponent(),
                    onTrackChanged: comp.setTrack,
                    onOpenEditor: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FullAnimationEditorPage(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SoundComponentPanel extends StatelessWidget {
  const SoundComponentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        
        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) {
              final comp = entity.getComponent<SoundControllerComponent>();
              if (comp == null) {
                return const Center(
                  child: Text(
                    'No sound component found',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return ChangeNotifierProvider.value(
                value: comp,
                child: Consumer<SoundControllerComponent>(
                  builder: (context, comp, child) {
                    final trackNames = comp.tracks.keys.toList();

                    return SoundControllerWidget(
                      options: trackNames,
                      initiallyChecked: comp.isActive,
                      initiallySelection: comp.currentlyPlaying,
                      onToggleChecked: (_) => comp.toggleComponent(),
                      onTrackChanged: comp.setTrack,
                      onOpenEditor: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FullSoundPage()),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class NodeComponentPanel extends StatelessWidget {
  final Entity entity;
  const NodeComponentPanel({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    final nodeComponents = entity.getAllComponents<NodeComponent>();
    if (nodeComponents == null || nodeComponents.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Block Components (${nodeComponents.length})',
            style: const TextStyle(fontFamily: 'PressStart2P', fontSize: 15)),
        const SizedBox(height: 8),
        ...List.generate(nodeComponents.length, (index) {
          final nodeComponent = nodeComponents[index];
          return Card(
            color: const Color(0xFF222222),
            child: ListTile(
              title: Text(
                'Node Component #$index',
                style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 12,
                    color: Colors.white),
              ),
              leading: Checkbox(
                value: nodeComponent.isActive,
                onChanged: (value) {
                  if (value != null) {
                    nodeComponent.toggleComponent();
                  }
                },
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.all(Colors.transparent),
                side: const BorderSide(color: Colors.white, width: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NodeWorkspaceTest()),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }
}


class VariablesDisplay extends StatelessWidget {
  const VariablesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        
        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) {
              return SizedBox(
                width: double.infinity,
                child: Card(
                  color: const Color(0xffE8E8E8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variables',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (entity.variables.isEmpty)
                          const Text(
                            'No variables declared',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                            ),
                          )
                        else
                          ...entity.variables.entries.map((entry) {
                            final key = entry.key;
                            final value = entry.value;

                            if (value is bool) {
                              return CheckboxListTile(
                                title: Text(
                                  key,
                                  style: const TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 12,
                                  ),
                                ),
                                value: value,
                                onChanged: (newValue) =>
                                    entity.setVariableXToValueY(key, newValue!),
                                checkColor: Colors.white,
                                fillColor: MaterialStateProperty.all(Colors.transparent),
                                side: const BorderSide(color: Colors.white, width: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            } else if (value is int || value is double) {
                              return PixelatedSlider(
                                value: (value as num).toDouble(),
                                min: -1.0,
                                max: 1.0,
                                onChanged: (newValue) => entity.setVariableXToValueY(
                                  key,
                                  value is int ? newValue.round() : newValue,
                                ),
                                label: '$key: $value',
                                divisions: 100,
                              );
                            } else {
                              return PixelatedTextField(
                                controller: TextEditingController(text: value.toString()),
                                hintText: key,
                                onChanged: (newValue) =>
                                    entity.setVariableXToValueY(key, newValue),
                              );
                            }
                          }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}