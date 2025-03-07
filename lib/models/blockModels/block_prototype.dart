import 'dart:ui';

import 'package:scratch_clone/models/blockModels/block_model.dart';

class BlockPrototype {
  static BlockModel createBlock(BlockModel block,Offset localOffset){
    return block.copyWith(position: localOffset,source: Source.workSpace);
  }
}