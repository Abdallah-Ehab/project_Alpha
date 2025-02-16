import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart' as custom;
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/block_factory.dart';


class DraggableOnlyBlock extends StatelessWidget {
  final BlockModel blockModel;
  const DraggableOnlyBlock(
      {super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    final blockProvider = Provider.of<BlockStateProvider>(context);
    var gameObjectManagerProvider = Provider.of<GameObjectManagerProvider>(context);
    return Draggable(
      data: blockModel,
      feedback: BlockFactory(blockModel: blockModel),
      childWhenDragging: BlockFactory(
          blockModel: blockModel),
      child: BlockFactory(blockModel: blockModel),
      onDragStarted: () {
        blockProvider.selectedBlock = blockModel;
        if(blockModel.state == custom.ConnectionState.connected){
          blockProvider.disconnectBlock(blockProvider.selectedBlock);
          gameObjectManagerProvider.addBlockToWorkSpaceBlocks(blockProvider.selectedBlock);
        }},
      onDragEnd: (details) {
        var draggedBlock = blockProvider.selectedBlock;
        blockProvider.updateBlockPosition(draggedBlock, details.offset);
      },
      
    );
  }
}