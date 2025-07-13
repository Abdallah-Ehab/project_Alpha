import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/text_ui_element/text_ui_element.dart';

class UiTextElementWidget extends StatelessWidget {
  final TextElement text;

  const UiTextElementWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final entity = EntityManager().getActorByName(text.entityName ?? '');

    return GestureDetector(
      onTap: () {
        if (!gameState.isPlaying) {
          showDialog(
            context: context,
            builder: (_) => text.buildUIElementController(),
          );
        }
      },
      child: SizedBox(
        width: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: entity == null
              ? Text(
                  'entity is null',
                  style: TextStyle(
                    fontFamily: text.fontFamily ?? 'PressStart2P',
                    color: text.color,
                  ),
                )
              : ChangeNotifierProvider.value(
                  value: entity,
                  child: Consumer<Entity>(
                    builder: (context, value, child) {
                      return Text(
                        entity.variables[text.boundVariable]?.toString() ?? 'Hello',
                        style: TextStyle(
                          fontFamily: text.fontFamily ?? 'PressStart2P',
                          color: text.color,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
