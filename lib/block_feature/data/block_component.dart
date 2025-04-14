// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:scratch_clone/block_feature/data/block_model.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';


class BlockComponent extends Component {
  late BlockModel? blockHead;
  Duration lastUpdate = Duration.zero;
  late List<BlockModel> workSpaceBlocks;

  BlockComponent() {
    blockHead = StartBlock(
      width: 150,
      height: 50,
      position: const Offset(100, 100),
      color: Colors.orange,
    );
    workSpaceBlocks = [blockHead!];
  }

  void addBlockToWorkSpace(BlockModel block) {
    workSpaceBlocks.add(block);
    blockHead ??= block;
    notifyListeners();
  }

  void removeBlockFromWorkSpace(BlockModel block) {
    workSpaceBlocks.remove(block);
    if (blockHead == block) blockHead = null;
    notifyListeners();
  }

  @override
  void update(Duration dt, {required Entity activeEntity,required EntityManager entityManager}) {
    var current = blockHead;
    
    while (current != null) {
      current.execute(activeEntity,entityManager);
      current = current.child;
    }
    notifyListeners();
  }
}



// abstract class BlockModel{
//   Offset position;
//   double height;
//   double width;
//   BlockModel? child;
//   BlockModel? parent;
//   bool isConnected;
//   Color color;
//   Source source;
//   bool isDragTarget;
//   BlockModel({required this.isDragTarget,required this.source,this.child,required this.position,required this.width,required this.height,this.parent,this.isConnected = false,required this.color});
  
//   Result execute([EntityManager? entityManager]);

//   BlockModel copyWith({
//     Offset? position,
//     double? height,
//     double? width,
//     BlockModel? child,
//     BlockModel? parent,
//     bool? isConnected,
//     Source? source,
//   });

//   BlockModel connectBlock(BlockModel childBlock){
//     if((childBlock.position - position).distance < 10 ){
//       return childBlock.copyWith(position: position - Offset(position.dx,height),parent: this,isConnected: true);
//     }else{
//       return this;
//     }
//   }

//   BlockModel disconnectBlock(){
//     return copyWith(isConnected: false,parent: null);
//   }

//   BlockModel updatePosition(Offset localOffset){
//     return copyWith(position: localOffset);
//   }

//   BlockModel addToWorkSpace(Offset localOffset){
//     return copyWith(position: localOffset,source: Source.workSpace);
//   }

// }




