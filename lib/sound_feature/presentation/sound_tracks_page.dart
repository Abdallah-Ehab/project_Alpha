import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

class TracksDisplayPage extends StatelessWidget {
  const TracksDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    final entity = entityManager.activeEntity;
    final soundComp = entity.getComponent<SoundControllerComponent>();

    if (soundComp == null) {
      return const Center(child: Text("No SoundControllerComponent found"));
    }

    return ChangeNotifierProvider.value(
      value: soundComp,
      child: Consumer<SoundControllerComponent>(
        builder: (context, soundComp, _) {
          final tracks = soundComp.tracks;

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final trackName = tracks.keys.elementAt(index);
              final track = tracks[trackName]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(trackName),
                  subtitle: Text("Path: ${track.filePath ?? 'bytes'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      soundComp.play(trackName);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
