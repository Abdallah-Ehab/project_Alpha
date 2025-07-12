import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class AddAnimationTransitionDialog extends StatefulWidget {
  final String entityName;

  const AddAnimationTransitionDialog({super.key, required this.entityName});

  @override
  State<AddAnimationTransitionDialog> createState() =>
      _AddAnimationTransitionDialogState();
}

class _AddAnimationTransitionDialogState
    extends State<AddAnimationTransitionDialog> {
  String fromTrack = '';
  String toTrack = '';
  String selectedVariable = '';
  String selectedOperator = '==';
  String secondOperand = '';

  final List<String> operators = ['==', '!=', '<', '>', '<=', '>='];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      title: const Text(
        "Add Animation Transition",
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<EntityManager>(
              builder: (context, entityManager, _) {
                final entity =
                    entityManager.getActorByName(widget.entityName);
                if (entity == null) {
                  return const Text(
                    "Entity not found",
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  );
                }

                final animationComponent =
                    entity.getComponent<AnimationControllerComponent>();
                if (animationComponent == null) {
                  return const Text(
                    "No Animation Component",
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  );
                }

                return ChangeNotifierProvider.value(
                  value: animationComponent,
                  child: Column(
                    children: [
                      Consumer<AnimationControllerComponent>(
                        builder: (context, animComponent, _) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'From Track',
                              labelStyle: TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: const Color(0xFF333333),
                            style: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            value: fromTrack.isNotEmpty &&
                                    animComponent.animationTracks
                                        .containsKey(fromTrack)
                                ? fromTrack
                                : null,
                            items: animComponent.animationTracks.keys
                                .map((trackName) {
                              return DropdownMenuItem(
                                value: trackName,
                                child: Text(trackName),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => fromTrack = value ?? ''),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Consumer<AnimationControllerComponent>(
                        builder: (context, animComponent, _) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'To Track',
                              labelStyle: TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: const Color(0xFF333333),
                            style: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            value: toTrack.isNotEmpty &&
                                    animComponent.animationTracks
                                        .containsKey(toTrack)
                                ? toTrack
                                : null,
                            items: animComponent.animationTracks.keys
                                .map((trackName) {
                              return DropdownMenuItem(
                                value: trackName,
                                child: Text(trackName),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => toTrack = value ?? ''),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Entity Variable',
                          labelStyle: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        dropdownColor: const Color(0xFF333333),
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        value: selectedVariable.isNotEmpty
                            ? selectedVariable
                            : null,
                        items: entity.variables.keys.map((varName) {
                          return DropdownMenuItem(
                            value: varName,
                            child: Text(varName),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedVariable = value ?? ''),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Operator',
                          labelStyle: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        dropdownColor: const Color(0xFF333333),
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        value: selectedOperator,
                        items: operators.map((op) {
                          return DropdownMenuItem(
                            value: op,
                            child: Text(op),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedOperator = value ?? '=='),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Second Operand (number)',
                          labelStyle: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.text,
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
        PixelArtButton(
          fontsize: 16,
          callback: () => Navigator.of(context).pop(),
          text: 'Cancel',
        ),
        const SizedBox(width: 16),
        PixelArtButton(
          fontsize: 16,
          callback: () {
            final entity = Provider.of<EntityManager>(context, listen: false)
                .getActorByName(widget.entityName);
            final animComponent =
                entity?.getComponent<AnimationControllerComponent>();

            if (entity == null || animComponent == null) return;

            if (fromTrack.isEmpty ||
                toTrack.isEmpty ||
                selectedVariable.isEmpty ||
                secondOperand.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please fill in all the fields to add a transition.",
                    style: TextStyle(fontFamily: 'PressStart2P'),
                  ),
                  backgroundColor: Colors.black,
                ),
              );
              return;
            }

            final condition = Condition(
              entityVariable: selectedVariable,
              secondOperand: secondOperand,
              operator: selectedOperator,
            );

            final transition = Transition(
              startTrackName: fromTrack,
              targetTrackName: toTrack,
              condition: condition,
            );

            animComponent.addTransition(transition);
            Navigator.of(context).pop();
          },
          text: 'OK',
        ),
      ],
    );
  }
}

