
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scratch_clone/models/animationModels/animation_track.dart';
import 'package:scratch_clone/models/blockModels/block_interface.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class GameObject {
  String name;
  Map<String, AnimationTrack> animationTracks;
  Offset position;
  double rotation;
  double width;
  double height;
  int activeFrameIndex;
  late AnimationController animationController;
  bool animationPlaying;
  BlockModel? blocksHead;
  late List<BlockModel> workSpaceBlocks;
  late GameObjectManagerProvider gameObjectManagerProvider;
late Ticker ticker;
  GameObject({
    required this.name,
    required TickerProvider vsync,
    required this.animationTracks,
    required this.position,
    required this.rotation,
    this.width = 200.0,
    this.height = 200.0,
    this.activeFrameIndex = 0,
    this.animationPlaying = false,
    required this.blocksHead,
  }) {
    animationController = AnimationController(vsync: vsync, duration: const Duration(seconds: 1));
    ticker = vsync.createTicker((elapsedTime){
      execute(elapsedTime);
    });
    workSpaceBlocks = [blocksHead!];
  }


  
  
  
  
  void stop(){
    ticker.stop();
  }
  
  
  

  Result<String> execute(Duration elapsedTime) {
 
    BlockModel? currentBlock = blocksHead;

    if (workSpaceBlocks.length > 1 || workSpaceBlocks.isEmpty) {
      log("please connect all the blocks");
      return Result.failure(errorMessage: "please connect all the blocks");
    }

    while (currentBlock != null) {
      Result result = currentBlock.execute(gameObjectManagerProvider, this);

      if (result.errorMessage != null) {
        log("${result.errorMessage}");
        stop();
        return Result.failure(errorMessage: result.errorMessage);
      }

      if (result.result == false) {
        while (currentBlock?.child != null) {
          if (currentBlock?.child is LabelBlock) {
            break;
          }
          currentBlock = currentBlock?.child;
        }
      }

      log("${result.result}");
      currentBlock = currentBlock?.child;
    }

    // Instead of returning, let the loop continue if necessary.
    return Result.success(result:"$name code executed successfully");
 
}

void play(GameObjectManagerProvider gameObjectManagerProvider){
this.gameObjectManagerProvider = gameObjectManagerProvider;
ticker.start();
}

  
}













