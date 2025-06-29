import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_editor_screen.dart';
import 'package:scratch_clone/animation_editor/presentation/full_animation_page.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/node_feature/data/node_component.dart';
import 'package:scratch_clone/node_feature/presentation/node_workspace_test.dart';
import 'package:scratch_clone/physics_feature/data/collider_component.dart';
import 'package:scratch_clone/physics_feature/presentation/collider_card_widget.dart';



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
        Text('Entity: ${entity.name}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(labelText: 'Name'),
          controller: nameController,
          onChanged: (value) => entity.setName(value),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'X'),
                keyboardType: TextInputType.number,
                controller: xController,
                onChanged: (value) => entity.teleport(dx: double.tryParse(value) ?? entity.position.dx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Y'),
                keyboardType: TextInputType.number,
                controller: yController,
                onChanged: (value) => entity.teleport(dy: double.tryParse(value) ?? entity.position.dy),
              ),
            ),
          ],
        ),
        Slider(
          value: entity.rotation,
          min: 0,
          max: 10,
          divisions: 10,
          label: 'Rotation: ${entity.rotation.toStringAsFixed(0)}°',
          onChanged: (value) => entity.rotate(value),
        ),
        Slider(
          value: entity.widthScale,
          min: 1.0,
          max: 10,
          divisions: 9,
          label: 'Width: ${entity.width.toStringAsFixed(1)}',
          onChanged: (value) => entity.scaleWidth(value),
        ),
        Slider(
          value: entity.heigthScale,
          min: 1.0,
          max: 10,
          divisions: 9,
          label: 'Height: ${entity.height.toStringAsFixed(1)}',
          onChanged: (value) => entity.scaleHeight(value),
        ),
      ],
    );
  }

  Widget _buildComponentPanels(BuildContext context, Entity entity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Components', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (entity.getComponent<AnimationControllerComponent>() != null)
          _buildAnimationComponentPanel(context, entity),
        if (entity.getAllComponents<NodeComponent>() != null)
          _buildNodeComponentPanel(context, entity),
        if (entity.getComponent<ColliderComponent>() != null)
          const ColliderCardWidget(),
      ],
    );
  }

  Widget _buildAnimationComponentPanel(BuildContext context, Entity entity) {
    final animationComponent = entity.getComponent<AnimationControllerComponent>()!;
    return Card(
      child: ListTile(
        title: const Text('Animation Component'),
        subtitle: ChangeNotifierProvider.value(
          value: animationComponent,
          child: Consumer<AnimationControllerComponent>(
            builder: (context, component, child) {
              return DropdownButton<String>(
                value: component.currentAnimationTrack.name,
                items: component.animationTracks.keys.map((trackName) {
                  return DropdownMenuItem<String>(
                    value: trackName,
                    child: Text(trackName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    component.setTrack(value);
                  }
                },
              );
            },
          ),
        ),
        leading: Checkbox(
          value: animationComponent.isActive,
          onChanged: (value) {
            if (value != null) {
              entity.toggleComponent(AnimationControllerComponent,0);
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FullAnimationEditorPage()),
          );
        },
      ),
    );
  }

Widget _buildNodeComponentPanel(BuildContext context, Entity entity) {
  final nodeComponents = entity.getAllComponents<NodeComponent>();
  if(nodeComponents == null) return SizedBox.expand();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Block Components (${nodeComponents?.length})',
          style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),

      ...List.generate(nodeComponents.length, (index) {
        final nodeComponent = nodeComponents[index];
        return Card(
          child: ListTile(
            title: Text('Node Component #$index'),
            leading: Checkbox(
              value: nodeComponent.isActive,
              onChanged: (value) {
                if (value != null) {
                  nodeComponent.toggleComponent();
                  
                }
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variables', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        if (entity.variables.isEmpty)
          const Text('No variables declared')
        else
          ...entity.variables.entries.map((entry) {
            final key = entry.key;
            final value = entry.value;
            if (value is bool) {
              return CheckboxListTile(
                title: Text(key),
                value: value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    entity.setVariableXToValueY(key, newValue);
                  }
                },
              );
            } else if (value is int || value is double) {
              return Slider(
                value: (value as num).toDouble(),
                min: -1.0,
                max: 1.0,
                divisions: 100,
                label: '$key: $value',
                onChanged: (newValue) {
                  entity.setVariableXToValueY(key, value is int ? newValue.round() : newValue);
                },
              );
            } else {
              return TextField(
                decoration: InputDecoration(labelText: key),
                controller: TextEditingController(text: value.toString()),
                onChanged: (newValue) {
                  entity.setVariableXToValueY(key, newValue);
                },
              );
            }
          }),
      ],
    );
  }
}