import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/ticker_state_provider.dart';

class PlayButton extends StatelessWidget {
  
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPlay(context),
      icon: const Icon(Icons.play_arrow_rounded),
    );
  }

  void onPlay(BuildContext context) {
    var gameLoopTicker =
        Provider.of<TickerStateProvider>(context, listen: false);

    if (!gameLoopTicker.isRunning) {
      gameLoopTicker.start();
    } else {
      gameLoopTicker.stop();
    }
  }
}
