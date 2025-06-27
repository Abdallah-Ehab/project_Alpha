import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/button_config_dialog.dart';

class TapButton extends UIButtonElement {
  TapButton({
    super.entityName,
    super.variableName,
    super.valueToSet,
    super.alignment = Alignment.center,
  });

  @override
  void trigger({required bool down}) {
    if (down) setVariable(valueToSet);
  }

  @override
  Widget buildWidget() {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return gameState.isPlaying
            ? GestureDetector(
                onTap: () => trigger(down: true),
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text("Tap"),
                ),
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
