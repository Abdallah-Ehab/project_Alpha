import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/button_config_dialog.dart';

class TapButton extends UIButtonElement {
  bool isTapped;
  TapButton({
    this.isTapped = false,
    super.entityName,
    super.variableName,
    super.valueToSet,
    super.alignment = Alignment.centerRight,
  });

  @override
  void trigger({required bool down}) {
    isTapped = !isTapped;
    setVariable(isTapped);
  }

  @override
  Widget buildWidget() {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return gameState.isPlaying
            ? GestureDetector(
              onTap: () => trigger(down: true),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                  color: Colors.greenAccent),
                ),
              )
            )
            : GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => buildUIElementController(),
                  );
                },
                child: const Icon(Icons.smart_button),
              );
      },
    );
  }

  @override
  Widget buildUIElementController() {
    return ButtonConfigDialog(buttonElement: this);
  }
}
