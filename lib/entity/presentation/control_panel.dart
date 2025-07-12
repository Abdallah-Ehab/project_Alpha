import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/full_animation_page.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/core/ui_widgets/animation_component.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/core/ui_widgets/sound_component_widget.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/presentation/entity_properties_panel.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/data/node_component_index_provider.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_card_widget.dart';
import 'package:scratch_clone/pose_detection_feature/data/pose_detection_component.dart';
import 'package:scratch_clone/pose_detection_feature/presentation/pose_detection_page.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';
import 'package:scratch_clone/sound_feature/presentation/full_sound_page.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  final nameController = TextEditingController();
  final xController = TextEditingController();
  final yController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    xController.dispose();
    yController.dispose();
    super.dispose();
  }

  void _updateControllers(Entity entity) {
    nameController.text = entity.name;
    xController.text = entity.position.dx.toStringAsFixed(2);
    yController.text = entity.position.dy.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(fontFamily: 'PressStart2P', fontSize: 16),
            ),
          );
        }
        _updateControllers(entity);

        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) => SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EntityPropertiesWidget(entity: entity),
                  const Divider(),
                  _buildComponentPanels(context, entity),
                  const Divider(),
                  _buildVariablesDisplay(context, entity),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildComponentPanels(BuildContext context, Entity entity) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Color(0xffCCCCCC),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Components',
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              if (entity.getComponent<AnimationControllerComponent>() != null)
                _buildAnimationComponentPanel(context, entity),
              if (entity.getAllComponents<NodeComponent>() != null)
                _buildNodeComponentPanel(context, entity),
              if (entity.getComponent<ColliderComponent>() != null)
                const ColliderCardWidget(),
              if (entity.getComponent<SoundControllerComponent>() != null)
                _buildSoundComponentControl(context, entity),
              if (entity.getComponent<RigidBodyComponent>() != null)
                RigidBodyComponentPanel(entity: entity),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationComponentPanel(BuildContext context, Entity entity) {
    final comp = entity.getComponent<AnimationControllerComponent>()!;
    final trackNames = comp.animationTracks.keys.toList();

    return AnimationControllerWidget(
      options: trackNames,
      initiallyChecked: comp.isActive,
      initiallySelection: comp.currentAnimationTrack.name,
      onToggleChecked: (isActive) {
        // toggles the component on/off
        entity.toggleComponent(AnimationControllerComponent, 0);
      },
      onTrackChanged: (trackName) {
        comp.setTrack(trackName);
      },
      onOpenEditor: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FullAnimationEditorPage(),
          ),
        );
      },
    );
  }

  Widget _buildSoundComponentControl(BuildContext context, Entity entity) {
    final comp = entity.getComponent<SoundControllerComponent>()!;
    final trackNames = comp.tracks.keys.toList();

    return SoundControllerWidget(
      options: trackNames,
      initiallyChecked: comp.isActive,
      initiallySelection: comp.currentlyPlaying,
      onToggleChecked: (isActive) {
        // toggles the component on/off
        entity.toggleComponent(AnimationControllerComponent, 0);
      },
      onTrackChanged: (trackName) {
        comp.setTrack(trackName);
      },
      onOpenEditor: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FullSoundPage(),
          ),
        );
      },
    );
  }


  Widget _buildNodeComponentPanel(BuildContext context, Entity entity) {
    final nodeComponents = entity.getAllComponents<NodeComponent>();
    if (nodeComponents == null) return SizedBox.expand();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Node Components (${nodeComponents.length})',
            style: TextStyle(fontFamily: 'PressStart2P', fontSize: 15)),
        const SizedBox(height: 8),
        ...List.generate(nodeComponents.length, (index) {
          final nodeComponent = nodeComponents[index];
          return Card(
            color: Color(0xFF333333),
            child: ListTile(
              title: Text(
                'Node Component #$index',
                style: TextStyle(
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
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  return Colors.transparent;
                }),
                side: const BorderSide(color: Colors.white, width: 2.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<NodeComponentIndexProvider>().index = index;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => ConnectionProvider(),
                        child: NodeWorkspaceTest(
                            nodeComponent: nodeComponent as NodeComponent),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVariablesDisplay(BuildContext context, Entity entity) {
   return ChangeNotifierProvider.value(
      value: entity,
      child: Consumer<Entity>(
        builder: (context, entity, child) =>  SizedBox(
          width: double.infinity,
          child: Card(
            color: Color(0xffE8E8E8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Variables',
                      style: TextStyle(
                          fontFamily: 'PressStart2P',
                          color: Colors.black,
                          fontSize: 18)),
                  const SizedBox(height: 10),
                  if (entity.variables.isEmpty)
                    const Text('No variables declared',
                        style: TextStyle(
                            fontFamily: 'PressStart2P',
                            color: Colors.black,
                            fontSize: 12))
                  else
                    ...entity.variables.entries.map((entry) {
                      final key = entry.key;
                      final value = entry.value;
                      if (value is bool) {
                        return CheckboxListTile(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith<Color>((states) {
                            return Colors.transparent;
                          }),
                          side: const BorderSide(color: Colors.white, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          title: Text(key,
                              style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  color: Colors.black,
                                  fontSize: 12)),
                          value: value,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              entity.setVariableXToValueY(key, newValue);
                            }
                          },
                        );
                      } else if (value is int || value is double) {
                        return PixelatedSlider(
                          value: (value as num).toDouble(),
                          min: -1.0,
                          max: 1.0,
                          onChanged: (newValue) {
                            entity.setVariableXToValueY(
                                key, value is int ? newValue.round() : newValue);
                          },
                          label: '$key: $value',
                          divisions: 100,
                        );
                      } else {
                        return PixelatedTextField(
                          
                          controller: TextEditingController(text: value.toString()),
                          hintText: key,
                          onChanged: (newValue) {
                            entity.setVariableXToValueY(key, newValue);
                          },
                        );
                      }
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class RigidBodyComponentPanel extends StatefulWidget {
  final Entity entity;

  const RigidBodyComponentPanel({super.key, required this.entity});

  @override
  State<RigidBodyComponentPanel> createState() =>
      _RigidBodyComponentPanelState();
}

class _RigidBodyComponentPanelState extends State<RigidBodyComponentPanel> {
  late TextEditingController massController;
  late TextEditingController gravityController;
  late TextEditingController fallSpeedController;
  late TextEditingController resistanceController;
  late TextEditingController frictionController;

  @override
  void initState() {
    super.initState();
    final comp = widget.entity.getComponent<RigidBodyComponent>()!;
    massController = TextEditingController(text: comp.mass.toStringAsFixed(2));
    gravityController =
        TextEditingController(text: comp.gravity.toStringAsFixed(2));
    fallSpeedController =
        TextEditingController(text: comp.maxFallSpeed.toString());
    resistanceController =
        TextEditingController(text: comp.velocity.dx.toStringAsFixed(2));
    frictionController =
        TextEditingController(text: comp.velocity.dy.toStringAsFixed(2));
  }

  @override
  void dispose() {
    massController.dispose();
    gravityController.dispose();
    fallSpeedController.dispose();
    resistanceController.dispose();
    frictionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comp = widget.entity.getComponent<RigidBodyComponent>()!;

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
                Text(
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
                      onChanged: (value) {
                        comp.toggleComponent();
                      },
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.all(Colors.transparent),
                      side: const BorderSide(color: Colors.white, width: 2.0),
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
                PixelatedTextField(
                  
                  label: 'mass',
                  labelColor: Colors.white,
                  controller: massController,
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
                PixelatedTextField(
                 
                  label: 'gravity',
                  labelColor: Colors.white,
                  controller: gravityController,
                  hintText: 'Gravity',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final gravity = double.tryParse(value) ?? comp.gravity;
                    comp.setGravity(gravity);
                  },
                ),
                const SizedBox(height: 10),
                PixelatedTextField(
                 
                  label: 'fallspeed',
                  labelColor: Colors.white,
                  controller: fallSpeedController,
                  hintText: 'fallSpeed',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final maxSpeed =
                        double.tryParse(value) ?? comp.maxFallSpeed;
                    comp.setMaxFall(maxSpeed);
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: PixelatedTextField(
                        
                        label: 'res',
                        labelColor: Colors.white,
                        controller: resistanceController,
                        hintText: 'Resistance',
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
                      child: PixelatedTextField(
                        
                        label: 'friction',
                        labelColor: Colors.white,
                        controller: frictionController,
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

                // Use Gravity Toggle
                Row(
                  children: [
                    Checkbox(
                      value: comp.useGravity,
                      onChanged: (value) {
                        comp.setUseGravity(value ?? comp.useGravity);
                      },
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.all(Colors.transparent),
                      side: const BorderSide(color: Colors.white, width: 2.0),
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

                // Static Toggle
                Row(
                  children: [
                    Checkbox(
                      value: comp.isStatic,
                      onChanged: (value) {
                        comp.setIsStatic(value ?? comp.isStatic);
                      },
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.all(Colors.transparent),
                      side: const BorderSide(color: Colors.white, width: 2.0),
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
                        color: comp.isGrounded ? Colors.green : Colors.red,
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
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
