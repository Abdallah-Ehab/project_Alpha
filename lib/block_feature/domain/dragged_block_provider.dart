import 'package:flutter/widgets.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';

class DraggedBlockNotifier extends ChangeNotifier {

  BlockModel? _draggedBlock;

  DraggedBlockNotifier();



  BlockModel? get draggedBlock => _draggedBlock;

  set draggedBLock(BlockModel draggedBlock){
    _draggedBlock = draggedBlock;
  }

}



