import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/button_config_dialog.dart';

class LongPressButton extends UIButtonElement {
  LongPressButton({
    super.entityName,
    super.variableName,
    super.valueToSet,
    super.alignment = Alignment.center,
  });

  @override
  void trigger({required bool down}) {
    setVariable(down ? true : false);
  }

  @override
  Widget buildWidget() {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return gameState.isPlaying
            ? GestureDetector(
                onLongPress: () => trigger(down: true),
                onLongPressUp: ()=>trigger(down:false),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue
                  ),),
                )
              )
            : GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => buildUIElementController(),
                  );
                },
                child: const Icon(Icons.touch_app),
              );
      },
    );
  }

  @override
  Widget buildUIElementController() {
    return ButtonConfigDialog(buttonElement: this);
  }
}
