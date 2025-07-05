// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
// import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
// import 'package:scratch_clone/animation_feature/data/animation_track.dart';
// import 'package:scratch_clone/core/image_loader.dart';
// import 'package:scratch_clone/entity/data/entity_manager.dart';
// import 'package:scratch_clone/game_scene/test_game_loop.dart';
// import 'package:scratch_clone/node_feature/data/node_component.dart';
// import 'package:scratch_clone/physics_feature/data/collider_component.dart';
// import 'package:scratch_clone/physics_feature/data/rigid_body_component.dart';
// import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';
// import 'package:scratch_clone/sound_feature/data/sound_track.dart';

// class AddComponents extends StatelessWidget {
//   const AddComponents({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var entityManager = Provider.of<EntityManager>(context, listen: false);
//   var activeEntity = entityManager.activeEntity;
//   var ground = entityManager.entities[EntityType.actors]!["ground"]!;
//   activeEntity?.addComponent(AnimationControllerComponent());
//   activeEntity?.addComponent(NodeComponent());
//   activeEntity?.addComponent(ColliderComponent());
//   activeEntity?.addComponent(RigidBodyComponent());
//   activeEntity?.addComponent(SoundControllerComponent());

//   // add collider component to ground :
//   ground.addComponent(ColliderComponent());
//   ground.addComponent(RigidBodyComponent(isStatic: true));

//   var animComponent = activeEntity?.getComponent<AnimationControllerComponent>();
  
 
//   animComponent!.addTrack("idle", track: AnimationTrack("idle", [],false,true));
//   animComponent.addTrack("walk", track: AnimationTrack("walk", [],false,false));


//   ImageLoader.loadImages(animationName: "idle", character: "goku", animationLength: 4).then((value) {
//     var keyFrames = value.map((e) => KeyFrame(image: e, sketches: [])).toList();
//     animComponent.addFramesToAnimationTracK(trackName: "idle", frames : keyFrames);
//   });

//   ImageLoader.loadImages(animationName: "walk", character: "goku", animationLength: 6).then((value) {
//     var keyFrames = value.map((e) => KeyFrame(image: e, sketches: [])).toList();
//     animComponent.addFramesToAnimationTracK(trackName: "walk", frames : keyFrames);
//   });

//   var soundComponent = activeEntity.getComponent<SoundControllerComponent>();

//   soundComponent?.addTrack('breath', SoundTrack(name: 'breath', filePath: 'assets/sounds/breath.mp3', loop: true, releaseMode: ReleaseMode.loop));
//   soundComponent?.addTrack('boost', SoundTrack(name: 'boost', filePath:'assets/sounds/boost.mp3', loop:true, releaseMode:ReleaseMode.loop));




//     return const TestGameLoop();
//   }
// }