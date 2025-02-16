import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class DropDownMenu2 extends StatelessWidget {
  const DropDownMenu2({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    return DropdownButton(
      items: gameObjectProvider.currentGameObject.animationTracks.keys
          .map((data) => DropdownMenuItem(child: Text(data)))
          .toList(),
      onChanged: (value) {
        gameObjectProvider.setSelectedAnimationTrackByName(value);
      },
    );
  }
}