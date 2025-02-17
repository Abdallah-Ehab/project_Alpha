import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';


class GameObjectDropDownMenu extends StatelessWidget {
  const GameObjectDropDownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    return DropdownButton(
      value: gameObjectProvider.currentGameObject.name,
        items: gameObjectProvider.gameObjects.keys
            .map(
              (data) => DropdownMenuItem(
                value: data,
                child: Text(data),
              ),
            ).toList(),
        onChanged: (value) {
          gameObjectProvider.setCurrentGameObjectByName(value!);
        });
  }
}