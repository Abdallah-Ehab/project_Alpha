import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/image_picker.dart';
import 'package:scratch_clone/models/animationModels/key_frame_model.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'dart:ui' as ui;
class AddSpriteButton extends StatelessWidget {
  const AddSpriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    var frameProvider = Provider.of<FramesProvider>(context,listen: false);
    var gameObjectManager = Provider.of<GameObjectManagerProvider>(context);

    return ElevatedButton(
      onPressed: () async {
        int currentFrameIndex = frameProvider.activeFrameIndex;
        List<ui.Image>? images = await MYImagePicker.getInstance().pickImages();
        if(images != null && images.isNotEmpty){
          for(int i = 0 ; i < images.length ; i++){
             gameObjectManager.addFrameToAnimationTrack(
                                        KeyframeModel(
                                            FrameByFrameKeyFrame(data: [],image: images[i]),
                                            currentFrameIndex + i,
                                            TweenKeyFrame(
                                                position: const Offset(0, 0),
                                                scale: 1.0,
                                                rotation: 0.0),
                                            KeyFrameType.fullKey,
                                        ));
          }
        }
      },
      child: const Text('Add Sprite'),
    );
  }
}