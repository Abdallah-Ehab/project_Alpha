import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';


class ConditionBlockTargetWidget extends StatefulWidget {
  IfStatementBlock blockModel;
  ConditionBlockTargetWidget({super.key,required this.blockModel});

  @override
  State<ConditionBlockTargetWidget> createState() => _ConditionBlockTargetWidget();
}

class _ConditionBlockTargetWidget extends State<ConditionBlockTargetWidget> {
  @override
  Widget build(BuildContext context) {
    var blockProvider = Provider.of<BlockStateProvider>(context);
    return DragTarget(
    
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.purple),
                  width: 100,
                  height: 30,
                );
              },
              onAcceptWithDetails: (details){
                if(details.data.runtimeType != ConditionBlock){
                  return;
                }
                  blockProvider.connectInternalBlock(widget.blockModel, details.data as ConditionBlock);
               },
            );
  }
}