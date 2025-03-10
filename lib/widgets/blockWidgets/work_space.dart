import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/models/blockModels/block_prototype.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/draggable_block.dart';

class WorkSpace extends StatefulWidget {
  const WorkSpace({super.key});

  @override
  State<WorkSpace> createState() => _WorkSpaceState();
}

class _WorkSpaceState extends State<WorkSpace> {
  @override
  Widget build(BuildContext context) {
    final blockProvider = Provider.of<BlockStateProvider>(context);
    var gameObjectManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);
    return Container(
      color: Colors.grey,
      child: DragTarget<BlockModel>(
          builder: (context, candidateData, rejectedData) {
        return Stack(
          children: renderNestedBlocks(context),
        );
      }, onWillAcceptWithDetails: (details) {
        return true;
      }, onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset localOffset = renderBox.globalToLocal(details.offset);

        if (details.data.source == Source.storage) {
          BlockModel newBlock;
          newBlock = BlockPrototype.createBlock(details.data, localOffset);
          gameObjectManagerProvider.addBlockToWorkSpaceBlocks(newBlock);
          }

         else {
          var workSpaceBlocks =
              gameObjectManagerProvider.currentGameObject.workSpaceBlocks;
          var index = workSpaceBlocks
              .indexWhere((block) => block == blockProvider.selectedBlock);
          if (index != -1) {
            blockProvider.updateBlockPosition(
                blockProvider.selectedBlock, localOffset);
          }
        }
      }),
    );
  }

  Widget renderBLocks(BuildContext context, BlockModel block) {
    return Positioned(
      top: block.position!.dy,
      left: block.position!.dx,
      child: DraggableBlock(
              closeDrawer: (){},
              blockModel: block,
            ),
    );
  }

  List<Widget> renderNestedBlocks(BuildContext context) {
    List<Widget> blocksPositioned = [];
    var gameObejctManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);
    log("${gameObejctManagerProvider.currentGameObject.workSpaceBlocks.length}");
    for (var block
        in gameObejctManagerProvider.currentGameObject.workSpaceBlocks) {
      log("${block.position}");
      blocksPositioned.addAll(traverseAndRender(context, block));
    }

    return blocksPositioned;
  }

  List<Widget> traverseAndRender(BuildContext context, BlockModel block) {
    List<Widget> blocks = [];

    blocks.add(renderBLocks(context, block));

    if (block.child != null) {
      log("block id: ${block.blockId} has position ${block.position} has child ${block.child!.blockId} and the child is at position ${block.child!.position}");
      blocks.addAll(traverseAndRender(context, block.child!));
    }

    return blocks;
  }
}
