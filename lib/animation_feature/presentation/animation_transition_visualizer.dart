import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationTransitionVisualizer extends StatefulWidget {
  const AnimationTransitionVisualizer({super.key});

  @override
  State<AnimationTransitionVisualizer> createState() => _AnimationTransitionVisualizerState();
}

class _AnimationTransitionVisualizerState extends State<AnimationTransitionVisualizer> {
  final Map<String, Offset> _trackPositions = {};

  @override
  Widget build(BuildContext context) {
    final entity = Provider.of<Entity>(context);
    final animComponent = entity.getComponent<AnimationControllerComponent>();
    final List<Transition> transitions;
    final Map<String, AnimationTrack> tracks;

    if (animComponent != null) {
      transitions = animComponent.transitions;
      tracks = animComponent.animationTracks;
    } else {
      return const Center(
        child: Text("No animation component or animation transitions"),
      );
    }

    final random = Random();

    return 
      
      Scaffold(
        body: InteractiveViewer(
          constrained: false,
          minScale: 0.5,
          maxScale: 2.5,
          child: SizedBox(
            width: 5000,
            height: 5000,
            child: Stack(
              children: [
                // Background grid
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/grid_placeholder.png', // <-- Replace later with your actual grid image
                    fit: BoxFit.cover,
                  ),
                ),
            
                // Arrows between nodes
                Positioned.fill(
                  child: CustomPaint(
                    painter: TransitionArrowPainter(
                      transitions: transitions,
                      trackPositions: _trackPositions,
                    ),
                  ),
                ),
            
                // Track boxes
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
                          color: trackName == 'idle' ? Colors.red : Colors.teal,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trackName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
  
  }
}

class TransitionArrowPainter extends CustomPainter {
  final List<Transition> transitions;
  final Map<String, Offset> trackPositions;

  TransitionArrowPainter({
    required this.transitions,
    required this.trackPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (final transition in transitions) {
      final from = trackPositions[transition.startTrackName];
      final to = trackPositions[transition.targetTrackName];

      if (from == null || to == null) continue;

      final start = Offset(from.dx + 60, from.dy + 30); // center right of source box
      final end = Offset(to.dx, to.dy + 30); // center left of target box

      canvas.drawLine(start, end, paint);
      _drawArrowhead(canvas, paint, start, end);
    }
  }

  void _drawArrowhead(Canvas canvas, Paint paint, Offset start, Offset end) {
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowLength = 10;
    const arrowAngle = pi / 6;

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowLength * cos(angle - arrowAngle),
        end.dy - arrowLength * sin(angle - arrowAngle),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowLength * cos(angle + arrowAngle),
        end.dy - arrowLength * sin(angle + arrowAngle),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TransitionArrowPainter oldDelegate) => true;
}
