import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/draggable_block.dart';


class ConditionBlockTargetWidget extends StatefulWidget {
  IfStatementBlock blockModel;
  ConditionBlockTargetWidget({super.key,required this.blockModel});
  
  @override
  State<ConditionBlockTargetWidget> createState() => _ConditionBlockTargetWidget();
}

class _ConditionBlockTargetWidget extends State<ConditionBlockTargetWidget> {
  final List<ConditionBlock> droppedWidgets = [];
  @override
  Widget build(BuildContext context) {
    var blockProvider = Provider.of<BlockStateProvider>(context);
    var gameObejctManagerProvider = Provider.of<GameObjectManagerProvider>(context);
    return DragTarget<ConditionBlock>(
      builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.purpleAccent),
                  width: 200,
                  height: 30,
                  child: 
                  Stack(children: blockProvider.conditionBlocks.map((ele){
                    log("block id is ${ele.blockId}");
                    return DraggableBlock(blockModel: ele,);
                  }).toList(),),
                );
              },
              onAcceptWithDetails: (details){
                  
                  blockProvider.addToListOfConditionBlocks(details.data);
                  blockProvider.connectInternalBlock(widget.blockModel, details.data);
                   gameObejctManagerProvider.removeBlockFromWorkSpaceBlocks(details.data);
                  log("${droppedWidgets.length}");
                  log(droppedWidgets.toString());
               },
            );
  }
}