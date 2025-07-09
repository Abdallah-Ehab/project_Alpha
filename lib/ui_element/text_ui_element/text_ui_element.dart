import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/text_config_dialog.dart';
import 'package:scratch_clone/ui_element/ui_element.dart';

class TextElement extends UIElement {
  String? boundVariable;
  String? entityName;
  String? fontFamily;
  String? value;

  TextElement({
    required super.alignment,
    this.boundVariable,
    this.entityName,
    this.fontFamily,
    this.value,
  }) : super(type: UIElementType.text);

  @override
  Widget buildWidget() {
    final entity = entityName != null ? EntityManager().getActorByName(entityName!) : null;

    // Fallback to stored `value` only if no entity or variable found.
    final displayValue = (entity != null && boundVariable != null)
        ? entity.variables[boundVariable]?.toString()
        : value ?? "";

    return Consumer<GameState>(
      builder: (BuildContext context, GameState gameState, Widget? child) => Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: () {
            if (!gameState.isPlaying) buildUIElementController();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              displayValue ?? '',
              style: TextStyle(
                fontFamily: fontFamily ?? 'PressStart2P',
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildUIElementController() {
    return  TextElementConfigDialog(textElement: this,); // Placeholder for dialog trigger in editor
  }
}
