import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class UploadFramesButton extends StatelessWidget {
  const UploadFramesButton({super.key});

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
                            allowMultiple: true,
                            type: FileType.image,
                          );

                          if (result == null || result.files.isEmpty) return;

                          List<KeyFrame> newFrames = [];

                          for (final file in result.files) {
                            final bytes = await File(file.path!).readAsBytes();
                            final decoded = img.decodeImage(bytes);
                            if (decoded == null) continue;

                            final resized = img.copyResize(decoded,
                                width: 140, height: 140);
                            final pngBytes = img.encodePng(resized);

                            // Convert to base64
                            final base64Str = base64Encode(pngBytes);

                            // Convert to ui.Image
                            final codec = await ui.instantiateImageCodec(
                                Uint8List.fromList(pngBytes));
                            final frameInfo = await codec.getNextFrame();
                            final image = frameInfo.image;

                            final frame = KeyFrame(
                              image: image,
                              sketches: [],
                              position: Offset.zero,
                              rotation: 0,
                              scale: 1.0,
                            );
                            frame.imageBase64 = base64Str;

                            newFrames.add(frame);
                          }

                          currentTrack.addMultipleFrames(newFrames);
                        }, fontsize: 16,);
                  },
                ));
          }
        },
      ),
    );
  }
}
