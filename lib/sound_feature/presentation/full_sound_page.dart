import 'package:flutter/material.dart';
import 'package:scratch_clone/sound_feature/presentation/sound_tracks_page.dart';
import 'package:scratch_clone/sound_feature/presentation/sound_transition_page.dart';

class FullSoundPage extends StatelessWidget {
  const FullSoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sound System"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tracks"),
              Tab(text: "Transitions"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TracksDisplayPage(),
            SoundTransitionPage(),
          ],
        ),
      ),
    );
  }
}
