import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_editor_screen.dart';
import 'package:scratch_clone/animation_editor/presentation/full_animation_page.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_feild.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_card_widget.dart';

import '../../core/ui_widgets/animation_component.dart';

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
        _updateControllers(entity);

        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) => SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEntityProperties(context, entity),
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

  Widget _buildEntityProperties(BuildContext context, Entity entity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Color(0xffE8E8E8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entity: ${entity.name}',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                PixelatedTextField(
                  keyboardType: TextInputType.text,
                  controller: nameController,
                  hintText: 'Name',
                  onChanged: (value) => entity.setName(value),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: PixelatedTextField(
                        controller: xController,
                        hintText: 'Position X',
                        onChanged: (value) => entity.teleport(
                            dx: double.tryParse(value) ?? entity.position.dx),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PixelatedTextField(
                        controller: yController,
                        hintText: 'Position Y',
                        onChanged: (value) => entity.teleport(
                            dy: double.tryParse(value) ?? entity.position.dy),
                      ),
                    ),
                  ],
                ),
                PixelatedSlider(
                  label: 'Rotation: ${entity.rotation.toStringAsFixed(0)}°',
                  divisions: 10,
                  max: 10,
                  min: 0,
                  value: entity.rotation,
                  onChanged: (value) => entity.rotate(value),
                ),
                PixelatedSlider(
                  label: 'Width: ${entity.width.toStringAsFixed(1)}',
                  divisions: 9,
                  max: 10,
                  min: 1.0,
                  value: entity.widthScale,
                  onChanged: (value) => entity.scaleWidth(value),
                ),
                PixelatedSlider(
                    max: 10,
                    min: 1.0,
                    divisions: 9,
                    value: entity.heigthScale,
                    onChanged: (value) => entity.scaleHeight(value),
                    label: 'Height: ${entity.height.toStringAsFixed(1)}'),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildComponentPanels(BuildContext context, Entity entity) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Color(0xffE8E8E8),
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
              if (entity.getComponent<AnimationControllerComponent>() != null)
                _buildAnimationComponentPanel(context, entity),
              if (entity.getAllComponents<NodeComponent>() != null)
                _buildNodeComponentPanel(context, entity),
              if (entity.getComponent<ColliderComponent>() != null)
                const ColliderCardWidget(),
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

  Widget _buildNodeComponentPanel(BuildContext context, Entity entity) {
    final nodeComponents = entity.getAllComponents<NodeComponent>();
    if (nodeComponents == null) return SizedBox.expand();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Block Components (${nodeComponents?.length})',
            style: TextStyle(fontFamily: 'PressStart2P', fontSize: 15)),
        const SizedBox(height: 8),
        ...List.generate(nodeComponents.length, (index) {
          final nodeComponent = nodeComponents[index];
          return Card(
            color: Color(0xFF222222),
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
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NodeWorkspaceTest(),
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
    return SizedBox(
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
    );
  }
}
