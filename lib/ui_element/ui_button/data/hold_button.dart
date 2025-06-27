import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/data/abstract_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/button_config_dialog.dart';

class HoldButton extends UIButtonElement {
  HoldButton({
    super.entityName,
    super.variableName,
    super.valueToSet = true,
    super.alignment = Alignment.center,
  });

  @override
  void trigger({required bool down}) {
    setVariable(down ? valueToSet : false);
  }

  @override
  Widget buildWidget() {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        return gameState.isPlaying
            ? GestureDetector(
                onTapDown: (_) => trigger(down: true),
                onTapUp: (_) => trigger(down: false),
                onTapCancel: () => trigger(down: false),
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text("Hold"),
                ),
              )
            : GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => buildUIElementController(),
                  );
                },
                child: const Icon(Icons.radio_button_checked),
              );
      },
    );
  }

  @override
  Widget buildUIElementController() {
    return ButtonConfigDialog(buttonElement: this);
  }
}
