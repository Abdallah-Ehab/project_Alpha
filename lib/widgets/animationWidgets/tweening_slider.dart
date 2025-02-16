import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';


class TweeningSlider extends StatelessWidget {
  const TweeningSlider({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    var frameProvider = Provider.of<FramesProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Slider(
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.position.dx,
          onChanged: (value) {
            gameObjectProvider.changeLocalPosition(frameProvider.activeFrameIndex,dx: value);
          },
          label: "X-axis",
          
          divisions: 20,
          min: -100,
          max: 100,
        ),
        Slider(
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.position.dy,
          onChanged: (value) {
            gameObjectProvider.changeLocalPosition(frameProvider.activeFrameIndex,dy: value);
          },
          label: "Y-axis",
          divisions: 20,
          min: -100,
          max: 100,
        ),
        Slider(
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.rotation,
          onChanged: (value) {
            gameObjectProvider.changeLocalRotation(frameProvider.activeFrameIndex,rotation: value);
          },
          label: "Rotation",
          divisions: 10,
          min: -pi,
          max: pi,
        ),
        Slider(
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.scale,
          onChanged: (value) {
             gameObjectProvider.changeLocalScale(frameProvider.activeFrameIndex,scale: value);
          },
          label: "Scale",
          divisions: 10,
          min: -1,
          max: 1,
        ),
      ],
    );
  }
}