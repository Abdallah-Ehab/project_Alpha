import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';
import 'package:scratch_clone/sound_feature/data/sound_track.dart';

class UploadSoundButton extends StatelessWidget {
  const UploadSoundButton({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();

    return ChangeNotifierProvider.value(
      value: entityManager.activeEntity,
      child: Consumer<Entity>(
        builder: (context, entity, child) {
          final soundComp = entity.getComponent<SoundControllerComponent>();
          if (soundComp == null) {
            return Center(
              child: Text('No Sound Component'),
            );
          } else {
            return ChangeNotifierProvider.value(
              value: soundComp,
              child: Consumer<SoundControllerComponent>(
                builder: (context, soundController, _) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.audiotrack),
                    label: const Text("Add Sound by File"),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'wav', 'ogg'],
                      );

                      if (result == null || result.files.isEmpty) return;

                      final file = result.files.first;
                      final path = file.path;

                      if (path == null) return;

                      // Ask for a name
                      final trackName =
                          await _askForName(context, defaultName: file.name);
                      if (trackName == null || trackName.trim().isEmpty) return;
                      final newTrack = SoundTrack(
                          name: trackName.trim(),
                          filePath: path,
                          loop: true,
                          releaseMode: ReleaseMode.loop);
                      soundController.addTrack(trackName.trim(), newTrack);
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future<String?> _askForName(BuildContext context,
      {required String defaultName}) async {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Name Your Sound Track"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Track name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
