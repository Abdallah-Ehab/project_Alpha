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
        var animationComponent =
            activeEntity.getComponent<AnimationControllerComponent>();
        if (animationComponent == null) {
          return const Center(
            child: Text("no animation Component"),
          );
        } else {
          return ChangeNotifierProvider.value(
            value: animationComponent,
            child: Consumer<AnimationControllerComponent>(
              builder: (context, animationComponent, child) {
                var currentAnimationTrack =
                    animationComponent.currentAnimationTrack;

                return ChangeNotifierProvider.value(
                  value: currentAnimationTrack,
                  child: Consumer<AnimationTrack>(
                    builder: (context, currentAnimationTrack, child) {
                      return ListView.builder(
                        itemCount: currentAnimationTrack.frames.length + 1,
                        itemBuilder: (context, index) {
                          return index ==
                                  currentAnimationTrack.frames.length + 1
                              ? GestureDetector(
                                  onTap: () {
                                    currentAnimationTrack
                                        .addFrame(KeyFrame(sketches: []));
                                    animationComponent.currentFrame++;
                                  },
                                  onLongPress: () {
                                    //Todo add a dialog box where the user can specify the number of frames to add and add this number of frames and add this number to the currentFrame index to draw the latest frame in the canvas
                                  },
                                  child: Container(
                                    color: Colors.blue,
                                    child: const Icon(Icons.add),
                                  ),
                                )
                              : Container(
                                  color: Colors.blue,
                                  child: Text("$index"),
                                );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
