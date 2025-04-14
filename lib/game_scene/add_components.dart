import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/block_feature/data/block_component.dart';
import 'package:scratch_clone/core/image_loader.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_scene/test_game_loop.dart';

class AddComponents extends StatelessWidget {
  const AddComponents({super.key});

  @override
  Widget build(BuildContext context) {
    var entityManager = Provider.of<EntityManager>(context, listen: false);
  var activeEntity = entityManager.activeEntity;
  activeEntity.addComponent(AnimationControllerComponent());
  activeEntity.addComponent(BlockComponent());
  var animComponent = activeEntity.getComponent<AnimationControllerComponent>();

 
  animComponent!.addTrack("idle", track: AnimationTrack("idle", []));
  animComponent.addTrack("walk", track: AnimationTrack("walk", []));


  ImageLoader.loadImages(animationName: "idle", character: "goku", animationLength: 4).then((value) {
    var keyFrames = value.map((e) => KeyFrame(image: e, sketches: [])).toList();
    animComponent.addFramesToAnimationTracK(trackName: "idle", frames : keyFrames);
  });

  ImageLoader.loadImages(animationName: "walk", character: "goku", animationLength: 6).then((value) {
    var keyFrames = value.map((e) => KeyFrame(image: e, sketches: [])).toList();
    animComponent.addFramesToAnimationTracK(trackName: "walk", frames : keyFrames);
  });

    return const TestGameLoop();
  }
}