import 'package:flutter/material.dart';

void main() => runApp(AnimationEditorApp());

class AnimationEditorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimationTransitionPage(),
    );
  }
}

class AnimationTransitionPage extends StatefulWidget {
  @override
  State<AnimationTransitionPage> createState() => _AnimationTransitionPageState();
}

class _AnimationTransitionPageState extends State<AnimationTransitionPage> {
  final Map<String, Offset> trackPositions = {
    "idle": Offset(100, 100),
    "walk": Offset(300, 300),
  };

  String? draggingFrom;
  Offset? dragToPosition;

  void updateTrackPosition(String name, Offset newPos) {
    setState(() {
      trackPositions[name] = newPos;
    });
  }

  void startConnection(String trackName, Offset start) {
    setState(() {
      draggingFrom = trackName;
      dragToPosition = start;
    });
  }

  void updateConnection(Offset newOffset) {
    setState(() {
      dragToPosition = newOffset;
    });
  }

  void endConnection(String? toTrackName) {
    if (draggingFrom != null && toTrackName != null && draggingFrom != toTrackName) {
      print("Create transition from $draggingFrom to $toTrackName");
      // TODO: open a condition dialog and store transition
    }
    setState(() {
      draggingFrom = null;
      dragToPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: ArrowPainter(
              trackPositions: trackPositions,
              draggingFrom: draggingFrom,
              dragToPosition: dragToPosition,
            ),
          ),
          ...trackPositions.entries.map((entry) {
            return TrackCard(
              trackName: entry.key,
              position: entry.value,
              onDrag: (newPos) => updateTrackPosition(entry.key, newPos),
              onStartConnection: (startOffset) => startConnection(entry.key, startOffset),
              onUpdateConnection: updateConnection,
              onEndConnection: (toTrackName) => endConnection(toTrackName),
            );
          })
        ],
      ),
    );
  }
}

class TrackCard extends StatelessWidget {
  final String trackName;
  final Offset position;
  final void Function(Offset newPos) onDrag;
  final void Function(Offset start) onStartConnection;
  final void Function(Offset newOffset) onUpdateConnection;
  final void Function(String toTrackName) onEndConnection;

  const TrackCard({
    required this.trackName,
    required this.position,
    required this.onDrag,
    required this.onStartConnection,
    required this.onUpdateConnection,
    required this.onEndConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(position + details.delta),
        onPanStart: (details) => onStartConnection(position + Offset(60, 30)),
        onPanEnd: (details) => onEndConnection(trackName),
        onPanCancel: () => onEndConnection(trackName),
        onPanDown: (details) => onUpdateConnection(position + Offset(60, 30)),
        child: Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: Text(trackName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Map<String, Offset> trackPositions;
  final String? draggingFrom;
  final Offset? dragToPosition;

  ArrowPainter({required this.trackPositions, this.draggingFrom, this.dragToPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw current dragging arrow
    if (draggingFrom != null && dragToPosition != null) {
      final start = trackPositions[draggingFrom!]! + Offset(60, 30);
      canvas.drawLine(start, dragToPosition!, paint);
    }

    // TODO: later draw saved transitions
  }

  @override
  bool shouldRepaint(covariant ArrowPainter oldDelegate) => true;
}
