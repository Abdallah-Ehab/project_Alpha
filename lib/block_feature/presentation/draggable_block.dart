import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';
import 'package:scratch_clone/block_feature/domain/dragged_block_provider.dart';
import 'package:scratch_clone/block_feature/presentation/block_factory.dart';

class DraggableBlock extends StatelessWidget {
  final BlockModel blockModel;
  final void Function()? removeStatement;
  final void Function()? removeCondition;
  const DraggableBlock({super.key, required this.blockModel,this.removeStatement,this.removeCondition});

  @override
  Widget build(BuildContext context) {
    return blockModel.isDragTarget
        ? DragTarget<BlockModel>(
            builder: (context, accepted, denied) {
              return Draggable(
                  data: blockModel,
                  feedback: Transform.scale(
                    scale: 1.09,
                    child: BlockFactory(blockModel: blockModel),
                  ),
                  child: BlockFactory(blockModel: blockModel),
                  onDragStarted: () {
                    if(blockModel.isStatement && removeStatement != null){
                      removeStatement!();
                    }
                    if(blockModel is ConditionBlock && removeCondition != null){
                      removeCondition!();
                    }
                  if(blockModel.isConnected){
                    blockModel.disconnectBlock();
                    log("block $blockModel was disconnected");
                    blockModel.hasExecuted = false;
                  }
                  if(Scaffold.of(context).isDrawerOpen) {
                    Scaffold.of(context).closeDrawer();
                  }
                  },
                  
                  // onDragUpdate: (details) {
                  //   blockModel.updatePosition(details.globalPosition);
                  //   if(blockModel.child != null){
                  //     blockModel.child!.updatePosition(blockModel.position + Offset(0, blockModel.height));
                  //   }
                  // },
                  );
                  
            },
            onAcceptWithDetails: (details) {
              log("${details.data}");
              log("$blockModel");

              if (blockModel.id != details.data.id) {
                details.data.updatePosition(
                    blockModel.position + Offset(0, blockModel.height));
                blockModel.connectBlock(details.data);
                log("block ${details.data} is connected to block $blockModel");
              }
            },
          )
        : Draggable(
            data: blockModel,
            feedback: BlockFactory(blockModel: blockModel),
            onDragUpdate: (details) {
              blockModel.updatePosition(details.localPosition);
            },
            onDragStarted: () {
              Provider.of<DraggedBlockNotifier>(context,listen: false).draggedBLock =
                  blockModel;
            },
            child: BlockFactory(blockModel: blockModel),
          );
  }
}
