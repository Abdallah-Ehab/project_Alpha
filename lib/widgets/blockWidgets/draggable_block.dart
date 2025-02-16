import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart' as custom;
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/block_factory.dart';



class DraggableBlock extends StatelessWidget {
  final BlockModel blockModel;
  const DraggableBlock({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    final blockProvider = Provider.of<BlockStateProvider>(context);
    var gameObjectManagerProvider = Provider.of<GameObjectManagerProvider>(context);
    GlobalKey key = GlobalKey();

    Widget draggableWidget = Draggable(
      data: blockModel,
      feedback: BlockFactory(blockModel: blockModel),
      childWhenDragging: BlockFactory(blockModel: blockModel),
      child: BlockFactory(blockModel: blockModel),
      onDragStarted: () {
        blockProvider.selectedBlock = blockModel;
        if (blockModel.state == custom.ConnectionState.connected) {
          blockProvider.disconnectBlock(blockProvider.selectedBlock);
          gameObjectManagerProvider.addBlockToWorkSpaceBlocks(blockProvider.selectedBlock);
        }
      },
     
    );

    // Check if the block should be a DragTarget
    if (blockModel.isDragTarget) {
      return DragTarget<BlockModel>(
        key: key,
        builder: (context, candidateData, rejectedData) {
          return draggableWidget;
        },
        onAcceptWithDetails: (details) {
          if(details.data is ConditionBlock){
            return;
          }

          var parentBlock = blockModel;
          var childBlock = details.data;
          log("Block number ${childBlock.blockId} is dropped on block number ${parentBlock.blockId}");
          blockProvider.connectBlock(parentBlock, childBlock);
          gameObjectManagerProvider.removeBlockFromWorkSpaceBlocks(childBlock);
         
        },
      );
    } else {
      return draggableWidget;
    }
  }
}