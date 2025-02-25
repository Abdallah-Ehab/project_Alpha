import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class AnimationTracksDropDownMenu extends StatelessWidget {
  const AnimationTracksDropDownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    return DropdownButton(
      value: "idle",
      items: gameObjectProvider.currentGameObject.animationTracks.keys
          .map((data) => DropdownMenuItem(value: data,child: Text(data),))
          .toList(),
      onChanged: (value) {
        gameObjectProvider.setSelectedAnimationTrackByName(value!);
      },
    );
  }
}