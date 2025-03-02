import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

class TweeningSlider extends StatelessWidget {
  const TweeningSlider({super.key});

  @override
  Widget build(BuildContext context) {
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    var frameProvider = Provider.of<FramesProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyledSlider(
          context,
          label: "X-Axis",
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.position.dx,
          onChanged: (value) {
            gameObjectProvider.changeLocalPosition(frameProvider.activeFrameIndex, dx: value);
          },
          min: -100,
          max: 100,
        ),
        _buildStyledSlider(
          context,
          label: "Y-Axis",
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.position.dy,
          onChanged: (value) {
            gameObjectProvider.changeLocalPosition(frameProvider.activeFrameIndex, dy: value);
          },
          min: -100,
          max: 100,
        ),
        _buildStyledSlider(
          context,
          label: "Rotation",
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.rotation,
          onChanged: (value) {
            gameObjectProvider.changeLocalRotation(frameProvider.activeFrameIndex, rotation: value);
          },
          min: -pi,
          max: pi,
        ),
        _buildStyledSlider(
          context,
          label: "Scale",
          value: gameObjectProvider.selectedAnimationTrack
              .keyFrames[frameProvider.activeFrameIndex].tweenData.scale,
          onChanged: (value) {
            gameObjectProvider.changeLocalScale(frameProvider.activeFrameIndex, scale: value);
          },
          min: -1,
          max: 1,
        ),
      ],
    );
  }

  /// **Custom Styled Slider Widget**
  Widget _buildStyledSlider(
    BuildContext context, {
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: MyColors.pastelPeach,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: MyColors.babyBlue,
            inactiveTrackColor: MyColors.coolGray.withOpacity(0.5),
            trackHeight: 6.0,
            thumbColor: MyColors.pastelPeach,
            overlayColor: MyColors.pastelPeach.withOpacity(0.3),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: 20,
          ),
        ),
      ],
    );
  }
}
