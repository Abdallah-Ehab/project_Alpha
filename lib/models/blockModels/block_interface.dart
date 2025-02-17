import 'package:flutter/material.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/models/gameObjectModels/game_object.dart';

import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';


abstract class BlockInterface {
  Result execute(GameObjectManagerProvider gameObjectProvider,GameObject gameObject);
  void connectChild(BlockModel child);
  Widget constructBlock();
}


abstract class HasInternalBlock<T extends BlockModel> {
  void connectInternalBlock(T? block);
}

abstract class LabelBlock{
  void registerLabel(GameObjectManagerProvider gameObejctManagerProvider);
}