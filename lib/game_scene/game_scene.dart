import 'package:flutter/widgets.dart';
import 'package:scratch_clone/entity/presentation/control_panel.dart';
import 'package:scratch_clone/game_scene/game_view.dart';
import 'package:scratch_clone/ui_element/ui_elements_layer.dart';

class GameScene extends StatelessWidget {
  const GameScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
          child: Stack(
            children: [
              // GameView as the background, expanded to fill available space
              const GameView(),
              // UIElementsLayer on top of GameView
              const UIElementsLayer()
            ],
          ),
                ),
        ),
        Expanded(
          flex: 3,
          child: ControlPanel(), // Control panel at the bottom
        ),]
    );
  }
}