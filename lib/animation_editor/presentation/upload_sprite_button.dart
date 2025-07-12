import 'dart:developer';
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
    return Consumer<EntityManager>(
      builder: (context, entityManager, child) {
        final entity = entityManager.activeEntity;
        if (entity == null) {
          return const Center(
            child: Text(
              'No active entity selected',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          );
        }

        return ChangeNotifierProvider.value(
          value: entity,
          child: Consumer<Entity>(
            builder: (context, entity, child) {
              final animComponent =
                  entity.getComponent<AnimationControllerComponent>();
              if (animComponent == null) {
                return const Center(
                  child: Text(
                    'No Animation Controller Component Added',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return ChangeNotifierProvider.value(
                value: animComponent,
                child: Consumer<AnimationControllerComponent>(
                  builder: (context, animationComponent, _) {
                    final currentTrack =
                        animationComponent.currentAnimationTrack;

                    return PixelArtButton(
                      text: "Upload Sprite Sheet",
                      fontsize: 16,
                      callback: () async {
                        final navigator = Navigator.of(context);
                        final scaffoldContext = context;

                        try {
                          log('Button pressed - starting file picker');

                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.image,
                          );

                          if (result == null || result.files.isEmpty) {
                            log('No file selected');
                            return;
                          }

                          final file = File(result.files.first.path!);
                          if (!await file.exists()) {
                            log('File does not exist');
                            return;
                          }

                          log('Reading file bytes...');
                          final bytes = await file.readAsBytes();

                          log('Creating UI Image directly...');
                          // Create UI Image directly without unnecessary conversions
                          final codec = await ui.instantiateImageCodec(bytes);
                          final frameInfo = await codec.getNextFrame();
                          final image = frameInfo.image;

                          log('Original image size: ${image.width}x${image.height}');
                          log('Navigating to SpriteSheetSlicer...');

                          await navigator.push(
                            MaterialPageRoute(
                              builder: (_) => SpriteSheetSlicer(
                                spriteSheet: image,
                                onSpritesExtracted: (List<ui.Image> images) {
                                  log('Sprites extracted: ${images.length}');

                                  final frames = images
                                      .map((img) => KeyFrame(
                                            image: img,
                                            sketches: [],
                                            position: Offset.zero,
                                            rotation: 0,
                                            scale: 1.0,
                                          ))
                                      .toList();

                                  currentTrack.addMultipleFrames(frames);

                                  if (scaffoldContext.mounted) {
                                    Navigator.of(scaffoldContext).pop();
                                  }
                                },
                              ),
                            ),
                          );
                        } catch (e, stackTrace) {
                          log('Error in upload sprite button: $e');
                          log('Stack trace: $stackTrace');

                          if (scaffoldContext.mounted) {
                            showDialog(
                              context: scaffoldContext,
                              builder: (_) => AlertDialog(
                                title: const Text('Error'),
                                content:
                                    Text('Failed to load sprite sheet: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(scaffoldContext).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}