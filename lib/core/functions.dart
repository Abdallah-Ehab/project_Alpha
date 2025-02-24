import 'dart:developer';
import 'dart:ui';

import 'package:scratch_clone/models/blockModels/block_interface.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/models/gameObjectModels/game_object.dart';

Offset lerpOffset(Offset start, Offset end, double t) {
  return Offset(
    start.dx + (end.dx - start.dx) * t,
    start.dy + (end.dy - start.dy) * t,
  );
}

double lerpDouble(double start, double end, double t) {
  return start + (end - start) * t;
}

Result<String> execute(GameObject gameObject) {
 
    BlockModel? currentBlock = gameObject.blocksHead;

    if (gameObject.workSpaceBlocks.length > 1 || gameObject.workSpaceBlocks.isEmpty) {
      log("please connect all the blocks");
      return Result.failure(errorMessage: "please connect all the blocks");
    }

    while (currentBlock != null) {
      Result result = currentBlock.execute(gameObject.gameObjectManagerProvider, gameObject);

      if (result.errorMessage != null) {
        log("${result.errorMessage}");
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
    return Result.success(result:"${gameObject.name} code executed successfully");
 
}