import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/upload_sprite_button.dart';

import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_scene/game_scene.dart';
import 'package:scratch_clone/game_state/game_state.dart';

class TestGameLoop extends StatefulWidget {
  const   TestGameLoop({super.key});

  @override
  State<TestGameLoop> createState() => _TestGameLoopState();
}

class _TestGameLoopState extends State<TestGameLoop>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  bool isPlaying = false;
  @override
  void initState() {
    _ticker = createTicker((elapsed) {
      
      var entityManager = Provider.of<EntityManager>(context, listen: false);
      entityManager.update(elapsed);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      body: const GameScene(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          ChangeNotifierProvider.value(
            value: gameState,
            child: Consumer<GameState>(
              builder: (context, gameState, child) =>  IconButton(
                color: Colors.white,
                onPressed: () {
                  if (!_ticker.isActive) {
                    gameState.isPlaying = true;
                    _ticker.start();
                  } else {
                    _ticker.stop();
                    EntityManager().reset();
                    gameState.isPlaying = false;
                  }
                },
                icon: gameState.isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
