import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/draggable_block.dart';



class StoredBlocks extends StatelessWidget {
  final VoidCallback closeDrawer; // Accept function as a parameter

  const StoredBlocks({super.key, required this.closeDrawer});

  @override
  Widget build(BuildContext context) {
    var blockProvider = Provider.of<BlockStateProvider>(context);
    return ListView.builder(
      itemCount: blockProvider.storedBlocks.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            DraggableBlock(
              blockModel: blockProvider.storedBlocks[index],
              closeDrawer: closeDrawer, // Pass function down
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
