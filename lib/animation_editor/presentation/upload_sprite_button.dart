import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/presentation/sprite_management_example.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class UploadSpriteButton extends StatelessWidget {
  const UploadSpriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    return ChangeNotifierProvider.value(
      value: entityManager.activeEntity,
      child: Consumer<Entity>(
        builder: (BuildContext context, Entity entity, Widget? child) {
          final animComponent =
              entity.getComponent<AnimationControllerComponent>();
          if (animComponent == null) {
            return Center(
              child: Text('No Animation Controller Component Added'),
            );
          } else {
            return ChangeNotifierProvider.value(
                value: animComponent,
                child: Consumer<AnimationControllerComponent>(
                  builder: (context, animationComponent, _) {
                    final currentTrack =
                        animationComponent.currentAnimationTrack;
                    if (currentTrack == null) return const SizedBox.shrink();

                    return PixelArtButton(
                        text: "Upload Frames",
                        callback: () async {
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                          );

                          if (result == null || result.files.isEmpty) return;

                          ui.Image image;

                          final bytes =
                              File(result.files.first.path!).readAsBytesSync();
                          final decoded = img.decodeImage(bytes);
                          if (decoded == null) return;

                          final resized =
                              img.copyResize(decoded);
                          final pngBytes = img.encodePng(resized);
                          final codec = await ui.instantiateImageCodec(
                              Uint8List.fromList(pngBytes));
                          final frameInfo = await codec.getNextFrame();

                          image = frameInfo.image;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SpriteSheetSlicer(
                                spriteSheet: image, 
                                onSpritesExtracted: (List<ui.Image> images) {
                                  List<KeyFrame> frames = [];
                                  for(final image in images){
                                    frames.add(KeyFrame(
                                      image: image,
                                      sketches: [],
                                      position: Offset.zero,
                                      rotation: 0,
                                      scale: 1.0,
                                    ));
                                  }
                                  currentTrack.addMultipleFrames(frames);
                                 },
                              ),
                            ),
                          );
                        }, fontsize: 16,);
                  },
                ));
          }
        },
      ),
    );
  }
}
