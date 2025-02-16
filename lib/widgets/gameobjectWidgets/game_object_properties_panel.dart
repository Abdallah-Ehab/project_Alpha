import 'package:flutter/material.dart';
import 'package:scratch_clone/widgets/gameobjectWidgets/add_game_object_button.dart';
import 'package:scratch_clone/widgets/gameobjectWidgets/game_object_drop_down_menu.dart';
import 'package:scratch_clone/widgets/gameobjectWidgets/game_object_translation_sliders.dart';

class GameObjectPropertiesPanel extends StatelessWidget {
  const GameObjectPropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GameObjectDropDownMenu(),
              AddGameObjectButton(),
            ],
          ),
          SizedBox(height: 20,)
          ,
          GameObjectTranslationSliders()
        ]
      ),
    );
  }
}