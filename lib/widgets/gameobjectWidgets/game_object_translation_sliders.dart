import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class GameObjectTranslationSliders extends StatelessWidget {
  const GameObjectTranslationSliders({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObejctManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);
    return Column(
      children: [
        Slider(
          min: -400,
          max: 400,
          divisions: 50,
          onChanged: (value) {
            gameObejctManagerProvider.changeGlobalPosition(dx: value,gameObject: gameObejctManagerProvider.currentGameObject);
          },
          value: gameObejctManagerProvider.currentGameObject.position.dx,
        ),
        const SizedBox(
          height: 20,
        ),
        Slider(
            min: -400,
            max: 400,
            divisions: 50,
            value: gameObejctManagerProvider.currentGameObject.position.dy,
            onChanged: (value) {
              gameObejctManagerProvider.changeGlobalPosition(dy: value,gameObject: gameObejctManagerProvider.currentGameObject);
            }),
        Slider(
          min: -pi,
          max: pi,
          divisions: 20,
          onChanged: (value) {
            gameObejctManagerProvider.changeGlobalRotation(value);
          },
          value: gameObejctManagerProvider.currentGameObject.rotation,
        ),
        Slider(
          min: 0,
          max: 10,
          divisions: 20,
          onChanged: (value) {
            gameObejctManagerProvider.changeGlobalScale(width: value);
          },
          value: gameObejctManagerProvider.currentGameObject.width,
        ),
        Slider(
          min: 0,
          max: 10,
          divisions: 20,
          onChanged: (value) {
            gameObejctManagerProvider.changeGlobalScale(height: value);
          },
          value: gameObejctManagerProvider.currentGameObject.height,
        ),
      ],
    );
  }
}



