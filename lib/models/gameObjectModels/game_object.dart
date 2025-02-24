import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scratch_clone/models/animationModels/animation_track.dart';
import 'package:scratch_clone/models/blockModels/block_interface.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class GameObject {
  String name;
  Map<String, AnimationTrack> animationTracks;
  Offset position;
  double rotation;
  double width;
  double height;
  int activeFrameIndex;
  late AnimationController animationController;
  bool animationPlaying;
  BlockModel? blocksHead;
  late List<BlockModel> workSpaceBlocks;
  GameObjectManagerProvider gameObjectManagerProvider;

  GameObject(
      {required this.name,
      required TickerProvider vsync,
      required this.animationTracks,
      required this.position,
      required this.rotation,
      this.width = 200.0,
      this.height = 200.0,
      this.activeFrameIndex = 0,
      this.animationPlaying = false,
      required this.blocksHead,
      required this.gameObjectManagerProvider}) {
    animationController =
        AnimationController(vsync: vsync, duration: const Duration(seconds: 1));
    workSpaceBlocks = [blocksHead!];
  }
}
