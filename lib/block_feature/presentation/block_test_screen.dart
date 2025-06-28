// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:scratch_clone/block_feature/data/block_component.dart';
// import 'package:scratch_clone/block_feature/data/block_model.dart';
// import 'package:scratch_clone/block_feature/presentation/draggable_block.dart';
// import 'package:scratch_clone/block_feature/presentation/work_space.dart';
// import 'package:scratch_clone/entity/data/entity_manager.dart';

// class BlockTestScreen extends StatelessWidget {
//   const BlockTestScreen({super.key});

//   // Default blocks in the drawer
//   static final List<BlockModel> storedBlocks = [
//     IfBlock(position: Offset.zero, color: Colors.green, width: 150, height: 75),
//     MoveBlock(position: Offset.zero, color: Colors.purple, width: 225, height: 50,x:1.0,y:0.0),
//     ConditionBlock(position: Offset.zero, color: Colors.orange, width: 150, height: 50),
//     DeclareVarableBlock(value: 0.0, position: Offset.zero, color: Colors.deepOrange, width: 250, height: 50),
//     VariableReferenceBlock(position: Offset.zero, color: Colors.deepPurple, width: 200, height: 50),  
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Block Test Screen'),
//         actions: [
//           // Button to add a new BlockComponent
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: 
//             () {
//               final entityManager = Provider.of<EntityManager>(context, listen: false);
//               final activeEntity = entityManager.activeEntity;
//               if (activeEntity.getComponent<BlockComponent>() == null) {
//                 activeEntity.addComponent(BlockComponent());
//               }
//             },
//             tooltip: 'Add Block Component',
//           ),
//           // Dropdown for selecting active entity
//           Consumer<EntityManager>(
//             builder: (context, entityManager, child) {
//               return DropdownButton<String>(
//                 value: entityManager.activeEntity.name,
//                 items: entityManager.allEntities.map((entity) {
//                   return DropdownMenuItem<String>(
//                     value: entity.name,
//                     child: Text(entity.name),
//                   );
//                 }).toList(),
//                 onChanged: (newName) {
//                   if (newName != null) {
//                     entityManager.setActiveEntityByName(EntityType.actors,newName);
//                   }
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text('Available Blocks', style: TextStyle(color: Colors.white, fontSize: 24)),
//             ),
//             ...storedBlocks.map((block) => 
//             Container(
//                     margin: const EdgeInsets.all(8.0),
//                     color: Colors.grey,
//                     height: block.height,
//                     width: block.width,
//                     child: DraggableBlock(blockModel: block)),
//                 ),
//           ],
//         ),
//       ),
//       body: const WorkSpace(),
//     );
//   }
// }