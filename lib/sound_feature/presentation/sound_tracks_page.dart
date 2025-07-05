import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';
import 'package:scratch_clone/sound_feature/presentation/upload_sound_track_using_path_button.dart';

class TracksDisplayPage extends StatelessWidget {
  const TracksDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    final entity = entityManager.activeEntity;
    final soundComp = entity?.getComponent<SoundControllerComponent>();

    if (soundComp == null) {
      return const Center(child: Text("No SoundControllerComponent found"));
    }

    return ChangeNotifierProvider.value(
      value: soundComp,
      child: Consumer<SoundControllerComponent>(
        builder: (context, soundComp, _) {
          final tracks = soundComp.tracks;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const UploadSoundButton(),
                const SizedBox(height: 12),
                ...tracks.entries.map((entry) {
                  final trackName = entry.key;
                  final track = entry.value;
                  final isPlaying = soundComp.currentlyPlaying == trackName;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ListTile(
                      title: Text(trackName),
                      subtitle:
                          Text("Path: ${track.filePath ?? 'bytes'}"),
                      trailing: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                        ),
                        onPressed: () async {
                          soundComp.togglePlay(trackName);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
