
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class MyTimeline extends StatelessWidget {
  const MyTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    return ChangeNotifierProvider.value(
      value: entityManager.activeEntity,
      child: Consumer<Entity>(
        builder: (context, activeEntity, child) {
          final animationComponent =
              activeEntity.getComponent<AnimationControllerComponent>();
      
          if (animationComponent == null) {
            return const Center(child: Text("No animation component"));
          }
      
          
      
          return ChangeNotifierProvider.value(
            value: animationComponent,
            child: Consumer<AnimationControllerComponent>(
              builder: (context, animComp, child) { 
                final currentTrack = animationComponent.currentAnimationTrack;
                return ChangeNotifierProvider.value(
                value: currentTrack,
                child: Consumer<AnimationTrack>(
                  builder: (context, value, child) => SizedBox(
                    height: 100,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentTrack.frames.length + 1,
                      onReorder: (oldIndex, newIndex) {
                        // Handle "add" icon at the end – don't allow dragging it
                        if (oldIndex >= currentTrack.frames.length ||
                            newIndex > currentTrack.frames.length) {
                          return;
                        }
                    
                        final frame = currentTrack.removeFrameAt(oldIndex);
                        currentTrack.insertFrameAt(
                            newIndex > oldIndex ? newIndex - 1 : newIndex, frame);
                    
                        // Update current frame index if affected
                        if (animationComponent.currentFrame == oldIndex) {
                          animationComponent.setFrame(
                              newIndex > oldIndex ? newIndex - 1 : newIndex);
                        } else if (animationComponent.currentFrame == newIndex) {
                          animationComponent.setFrame(newIndex);
                        }
                      },
                      itemBuilder: (context, index) {
                        if (index < currentTrack.frames.length) {
                          return KeyedSubtree(
                            key: ValueKey(index),
                            child: ChangeNotifierProvider.value(
                              value: animationComponent,
                              child: Consumer<AnimationControllerComponent>(
                                builder: (context, animComp, _) {
                                  final isSelected = animComp.currentFrame == index;
                                  return Container(
                                    decoration: BoxDecoration( color: isSelected ? Colors.white : Colors.grey,borderRadius: BorderRadius.circular(8)),
                                    width: 60,
                                    margin: const EdgeInsets.all(4),
                                   
                                    child: InkWell(
                                      onTap: () => animComp.setFrame(index),
                                      onDoubleTap: () {
                                        currentTrack.removeFrame(index);
                                        animComp.setFrame(
                                          min(animComp.currentFrame,
                                              currentTrack.frames.length - 1),
                                        );
                                      },
                                      child: Center(child: Text("$index",style: TextStyle(fontFamily: "PressStart2P",fontSize: 14),)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else {
                          // Add new frame
                          return Container(
                            decoration: BoxDecoration(color: Color(0xff888888),borderRadius: BorderRadius.circular(12)),
                            width: 60,
                            key: ValueKey('add'),
                            margin: const EdgeInsets.all(4),
                            
                            child: GestureDetector(
                              onTap: () {
                                currentTrack.addFrame(KeyFrame(sketches: []));
                                animationComponent
                                    .setFrame(currentTrack.frames.length - 1);
                              },
                              onLongPress: () {
                                _showAddFramesDialog(
                                    context, currentTrack, animationComponent);
                              },
                              child: const Icon(Icons.add),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );}
            ),
          );
        },
      ),
    );
  }

  void _showAddFramesDialog(BuildContext context, AnimationTrack track,
      AnimationControllerComponent animationComponent) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Multiple Frames"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter number of frames"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final count = int.tryParse(controller.text);
              if (count != null && count > 0) {
                final newFrames =
                    List.generate(count, (_) => KeyFrame(sketches: []));
                track.addMultipleFrames(newFrames);
                animationComponent.setFrame(track.frames.length - 1);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
