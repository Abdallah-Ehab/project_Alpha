// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';
// import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
// import 'package:scratch_clone/block_feature/data/block_model.dart';
// import 'package:scratch_clone/entity/data/entity.dart';

// class BlockFactory extends StatelessWidget {
//   final BlockModel blockModel;

//   const BlockFactory({super.key, required this.blockModel});

//   @override
//   Widget build(BuildContext context) {
//     return blockModel.buildBlock();
//   }
// }

// class StartBlockWidget extends StatelessWidget {
//   final StartBlock blockModel;
//   const StartBlockWidget({super.key, required this.blockModel});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: blockModel.width,
//       height: blockModel.height,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: blockModel.color,
//       ),
//       child: const Center(
//         child: Material(color: Colors.transparent, child: Text("start game")),
//       ),
//     );
//   }
// }






// class AnimationTracksDropDownMenu extends StatelessWidget {
//   final ValueChanged<dynamic>? onChange;
//   const AnimationTracksDropDownMenu({super.key, required this.onChange});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Entity>(
//       builder: (context, activeEntity, child) {
//         var animationcomponent =
//             activeEntity.getComponent<AnimationControllerComponent>();
//         if (animationcomponent == null) {
//           return const Text("no animation component avaialable");
//         } else {
//           return ChangeNotifierProvider.value(
//             value: animationcomponent,
//             child: Consumer<AnimationControllerComponent>(
//               builder: (context, animationComponent, child) {
//                 return Material(
//                   color: Colors.transparent,
//                   child: DropdownButton(
//                       items: animationComponent.animationTracks.keys
//                           .map((e) => DropdownMenuItem(child: Text(e)))
//                           .toList(),
//                       onChanged: onChange),
//                 );
//               },
//             ),
//           );
//         }
//       },
//     );
//   }
// }
