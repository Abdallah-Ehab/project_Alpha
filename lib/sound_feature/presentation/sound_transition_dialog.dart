import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

class AddSoundTransitionDialog extends StatefulWidget {
  final String entityName;

  const AddSoundTransitionDialog({super.key, required this.entityName});

  @override
  State<AddSoundTransitionDialog> createState() => _AddSoundTransitionDialogState();
}

class _AddSoundTransitionDialogState extends State<AddSoundTransitionDialog> {
  String fromTrack = '';
  String toTrack = '';
  String selectedVariable = '';
  String selectedOperator = '==';
  String secondOperand = '';

  final List<String> operators = const ['==', '!=', '>', '<', '>=', '<='];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Sound Transition"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<EntityManager>(
              builder: (context, entityManager, _) {
                final entity = entityManager.getActorByName(widget.entityName);
                if (entity == null) return const Text("Entity not found");

                final soundComponent = entity.getComponent<SoundControllerComponent>();
                if (soundComponent == null) return const Text("No Sound Component");

                return ChangeNotifierProvider.value(
                  value: soundComponent,
                  child: Column(
                    children: [
                      Consumer<SoundControllerComponent>(
                        builder: (context, soundComponent, _) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'From Track'),
                            value: fromTrack.isNotEmpty && soundComponent.tracks.containsKey(fromTrack)
                                ? fromTrack
                                : null,
                            items: soundComponent.tracks.keys.map((trackName) {
                              return DropdownMenuItem(
                                value: trackName,
                                child: Text(trackName),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => fromTrack = value ?? ''),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<SoundControllerComponent>(
                        builder: (context, soundComponent, _) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'To Track'),
                            value: toTrack.isNotEmpty && soundComponent.tracks.containsKey(toTrack)
                                ? toTrack
                                : null,
                            items: soundComponent.tracks.keys.map((trackName) {
                              return DropdownMenuItem(
                                value: trackName,
                                child: Text(trackName),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => toTrack = value ?? ''),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Entity Variable'),
                        value: selectedVariable.isNotEmpty ? selectedVariable : null,
                        items: entity.variables.keys.map((varName) {
                          return DropdownMenuItem(
                            value: varName,
                            child: Text(varName),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedVariable = value ?? ''),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Operator'),
                        value: selectedOperator,
                        items: operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                        onChanged: (value) => setState(() => selectedOperator = value ?? '=='),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Second Operand (number)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => secondOperand = value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final entity = Provider.of<EntityManager>(context, listen: false)
                .getActorByName(widget.entityName);
            final soundComponent = entity?.getComponent<SoundControllerComponent>();
            if (entity == null || soundComponent == null) return;

            final condition = Condition(
              entityVariable: selectedVariable,
              secondOperand: double.tryParse(secondOperand) ?? 0.0,
              operator: selectedOperator,
            );

            final transition = Transition(
              startTrackName: fromTrack,
              targetTrackName: toTrack,
              condition: condition,
            );

            soundComponent.addTransition(transition);
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
