import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/draggable_block.dart';



class StoredBlocks extends StatelessWidget {
   const StoredBlocks({super.key});

  
  @override
  Widget build(BuildContext context) {
    var blockProvider = Provider.of<BlockStateProvider>(context);
    return ListView.builder(
      itemCount: blockProvider.storedBlocks.length,
      itemBuilder: (context, index) {
        return DraggableBlock(
          blockModel: blockProvider.storedBlocks[index],
        );
      },
    );
  }
}