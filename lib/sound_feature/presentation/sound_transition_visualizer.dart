import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/presentation/animation_transition_visualizer.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

class SoundTransitionVisualizer extends StatefulWidget {
  const SoundTransitionVisualizer({super.key});

  @override
  State<SoundTransitionVisualizer> createState() => _SoundTransitionVisualizerState();
}

class _SoundTransitionVisualizerState extends State<SoundTransitionVisualizer> {
  final Map<String, Offset> _trackPositions = {};

  @override
  Widget build(BuildContext context) {
    final entity = Provider.of<Entity>(context);
    final soundComponent = entity.getComponent<SoundControllerComponent>();
    if (soundComponent == null) {
      return const Center(child: Text("No sound controller found"));
    }

    final transitions = soundComponent.transitions;
    final tracks = soundComponent.tracks;
    final random = Random();

    return Scaffold(
      appBar: AppBar(title: const Text("Sound Transition Visualizer")),
      body: InteractiveViewer(
        constrained: false,
        minScale: 0.5,
        maxScale: 2.5,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/grid_placeholder.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: TransitionArrowPainter(
                  transitions: transitions,
                  trackPositions: _trackPositions,
                ),
              ),
            ),
            ...tracks.keys.map((trackName) {
              final position = _trackPositions.putIfAbsent(
                trackName,
                () => Offset(
                  100 + random.nextDouble() * 300,
                  100 + random.nextDouble() * 400,
                ),
              );

              return Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _trackPositions[trackName] = position + details.delta;
                    });
                  },
                  child: Container(
                    width: 120,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(trackName, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
