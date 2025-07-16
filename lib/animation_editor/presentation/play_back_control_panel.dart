import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class PlayBackControlPanel extends StatefulWidget {
  const PlayBackControlPanel({super.key});

  @override
  State<PlayBackControlPanel> createState() => _PlayBackControlPanel();
}

class _PlayBackControlPanel extends State<PlayBackControlPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    final entity = context.read<EntityManager>().activeEntity;
    final animComp = entity?.getComponent<AnimationControllerComponent>();
    final track = animComp?.currentAnimationTrack;

    const fps = 12;
    final totalDuration = Duration(
      milliseconds: ((100) * (1000 ~/ fps)),
    );
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      });

    _controller.addListener(() {
      final entity = context.read<EntityManager>().activeEntity;
      final animComp = entity?.getComponent<AnimationControllerComponent>();
      final track = animComp?.currentAnimationTrack;

      if (track != null && track.frames.isNotEmpty) {
        animComp!.setFrame((animComp.currentFrame + 1) % track.frames.length);
      }
    });
  }

  void togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });

    if (isPlaying) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  void goToPreviousFrame() {
    final entity = context.read<EntityManager>().activeEntity;
    final animComp = entity?.getComponent<AnimationControllerComponent>();

    if (animComp != null && animComp.currentAnimationTrack.frames.isNotEmpty) {
      final current = animComp.currentFrame;
      final total = animComp.currentAnimationTrack.frames.length;
      animComp.setFrame((current - 1 + total) % total);
    }
  }

  void goToNextFrame() {
    final entity = context.read<EntityManager>().activeEntity;
    final animComp = entity?.getComponent<AnimationControllerComponent>();

    if (animComp != null &&
        animComp
            .currentAnimationTrack
            .frames
            .isNotEmpty) {
      final current = animComp.currentFrame;
      final total = animComp.currentAnimationTrack.frames.length;
      animComp.setFrame((current + 1) % total);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff444444),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: goToPreviousFrame,
        ),
      ),
    ),
    const SizedBox(width: 16),
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff444444),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        onPressed: togglePlayPause,
      ),
    ),
    const SizedBox(width: 16),
    Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff444444),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.skip_next, color: Colors.white),
        onPressed: goToNextFrame,
      ),
    ),
  ],
);
  }
}
