import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class Timeline extends StatelessWidget {
  const Timeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Entity>(
      builder: (context, activeEntity, child) {
        final animationComponent =
            activeEntity.getComponent<AnimationControllerComponent>();

        if (animationComponent == null) {
          return const Center(child: Text("No animation component"));
        }

        final currentTrack = animationComponent.currentAnimationTrack;

        return ChangeNotifierProvider.value(
          value: currentTrack,
          child: Consumer<AnimationTrack>(
            builder: (context, value, child) =>  SizedBox(
              height: 100,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentTrack.frames.length + 1,
                onReorder: (oldIndex, newIndex) {
                  // Handle "add" icon at the end – don't allow dragging it
                  if (oldIndex >= currentTrack.frames.length || newIndex > currentTrack.frames.length) return;
            
                  final frame = currentTrack.removeFrameAt(oldIndex);
                  currentTrack.insertFrameAt(newIndex > oldIndex ? newIndex - 1 : newIndex, frame);
                  
            
                  // Update current frame index if affected
                  if (animationComponent.currentFrame == oldIndex) {
                    animationComponent.setFrame(newIndex > oldIndex ? newIndex - 1 : newIndex);
                  } else if (animationComponent.currentFrame == newIndex) {
                    animationComponent.setFrame(newIndex);
                  }
                },
                itemBuilder: (context, index) {
                  if (index < currentTrack.frames.length) {
                    final isSelected = animationComponent.currentFrame == index;
                    return Container(
                      key: ValueKey(index),
                      width: 60,
                      margin: const EdgeInsets.all(4),
                      color: isSelected ? Colors.orange : Colors.grey,
                      child: InkWell(
                        onTap: () => animationComponent.setFrame(index),
                        onLongPress: () {
                          currentTrack.removeFrame(index);
                          animationComponent.setFrame(
                            min(animationComponent.currentFrame, currentTrack.frames.length - 1),
                          );
                        },
                        child: Center(child: Text("$index")),
                      ),
                    );
                  } else {
                    // Add new frame
                    return Container(
                      key: const ValueKey('add'),
                      width: 60,
                      margin: const EdgeInsets.all(4),
                      color: Colors.green,
                      child: GestureDetector(
                        onTap: () {
                          currentTrack.addFrame(KeyFrame(sketches: []));
                          animationComponent.setFrame(currentTrack.frames.length - 1);
                        },
                        onLongPress: () {
                          _showAddFramesDialog(context, currentTrack, animationComponent);
                        },
                        child: const Icon(Icons.add),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
