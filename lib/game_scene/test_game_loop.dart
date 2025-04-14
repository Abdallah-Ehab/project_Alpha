import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_scene/game_scene.dart';

class TestGameLoop extends StatefulWidget {
  const TestGameLoop({super.key});

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
    return Scaffold(
      body: const GameScene(),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (!_ticker.isActive) {
                _ticker.start();
                setState(() {
                  isPlaying = true;
                });
              } else {
                _ticker.stop();
                setState(() {
                  isPlaying = false;
                });
              }
            },
            icon: isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
