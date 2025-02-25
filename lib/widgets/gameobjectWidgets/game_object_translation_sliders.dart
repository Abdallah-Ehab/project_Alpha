import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class GameObjectTranslationSliders extends StatelessWidget {
  const GameObjectTranslationSliders({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);

    // Clamp position and reset if exceeded
    void updatePosition({double? dx, double? dy}) {
      double clampedDx = dx?.clamp(-400, 400) ?? gameObjectManagerProvider.currentGameObject.position.dx;
      double clampedDy = dy?.clamp(-400, 400) ?? gameObjectManagerProvider.currentGameObject.position.dy;

      gameObjectManagerProvider.changeGlobalPosition(
        dx: clampedDx,
        dy: clampedDy,
        gameObject: gameObjectManagerProvider.currentGameObject,
      );
    }

    // Clamp rotation between -π and π
    void updateRotation(double value) {
      double clampedRotation = value.clamp(-pi, pi);
      gameObjectManagerProvider.changeGlobalRotation(clampedRotation);
    }

    // Clamp scale (width/height) between 0 and 10
    void updateScale({double? width, double? height}) {
      double clampedWidth = width?.clamp(0, 10) ?? gameObjectManagerProvider.currentGameObject.width;
      double clampedHeight = height?.clamp(0, 10) ?? gameObjectManagerProvider.currentGameObject.height;

      gameObjectManagerProvider.changeGlobalScale(
        width: clampedWidth,
        height: clampedHeight,
      );
    }

    return Column(
      children: [
        // X Position Slider
        Slider(
          min: -400,
          max: 400,
          divisions: 50,
          value: gameObjectManagerProvider.currentGameObject.position.dx.clamp(-400, 400),
          onChanged: (value) => updatePosition(dx: value),
        ),
        const SizedBox(height: 20),

        // Y Position Slider
        Slider(
          min: -400,
          max: 400,
          divisions: 50,
          value: gameObjectManagerProvider.currentGameObject.position.dy.clamp(-400, 400),
          onChanged: (value) => updatePosition(dy: value),
        ),

        // Rotation Slider
        Slider(
          min: -pi,
          max: pi,
          divisions: 20,
          value: gameObjectManagerProvider.currentGameObject.rotation.clamp(-pi, pi),
          onChanged: updateRotation,
        ),

        // Width Scale Slider
        Slider(
          min: 0,
          max: 10,
          divisions: 20,
          value: gameObjectManagerProvider.currentGameObject.width.clamp(0, 10),
          onChanged: (value) => updateScale(width: value),
        ),

        // Height Scale Slider
        Slider(
          min: 0,
          max: 10,
          divisions: 20,
          value: gameObjectManagerProvider.currentGameObject.height.clamp(0, 10),
          onChanged: (value) => updateScale(height: value),
        ),
      ],
    );
  }
}



