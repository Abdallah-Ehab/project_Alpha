// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:scratch_clone/core/functions.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/models/gameObjectModels/game_object.dart';

// ignore: must_be_immutable
class GameObjectWidget extends StatelessWidget {

  GameObject gameObject;
  GameObjectWidget({super.key,required this.gameObject});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: gameObject.width,
        height: gameObject.height,
        child: CustomPaint(
          painter: GameObjectRenderer(
            widthFactor: MediaQuery.of(context).size.width,
            heightFactor: MediaQuery.of(context).size.height * 0.6,
            gameObject: gameObject,
            trackName: "idle",
          ),
        ),
      );
  }



}

class GameObjectRenderer extends CustomPainter {
  GameObject gameObject;
  String trackName;
  double widthFactor;
  double heightFactor;

  GameObjectRenderer({
    required this.widthFactor,
    required this.heightFactor,
    required this.gameObject,
    required this.trackName
  });

  
  @override
  void paint(Canvas canvas, Size size) {
  var currentAnimationTrack = gameObject.animationTracks[trackName];
  if (currentAnimationTrack!.keyFrames.isEmpty || 
      currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].sketches.data.isEmpty) return;

  Paint backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.3); // Light grey for visibility
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);



  int previousFrameIndex = ((currentAnimationTrack.fullKeyFramesIndices.length - 1) * gameObject.animationController.value).floor();
  int nextFrameIndex = ((currentAnimationTrack.fullKeyFramesIndices.length - 1) * gameObject.animationController.value).ceil();

  // Ensure valid indices
  previousFrameIndex = previousFrameIndex.clamp(0, currentAnimationTrack.fullKeyFramesIndices.length - 1);
  nextFrameIndex = nextFrameIndex.clamp(0, currentAnimationTrack.fullKeyFramesIndices.length - 1);

  int previousFullKeyFrameIndex = currentAnimationTrack.fullKeyFramesIndices[previousFrameIndex];
  int nextFullKeyFrameIndex = currentAnimationTrack.fullKeyFramesIndices[nextFrameIndex];

  // Interpolated values
  Offset positionInterpolation = lerpOffset(
      currentAnimationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.position,
      currentAnimationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.position,
      gameObject.animationController.value);

  double rotationInterpolation = lerpDouble(
      currentAnimationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.rotation,
      currentAnimationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.rotation,
      gameObject.animationController.value);

  double scaleInterpolation = lerpDouble(
      currentAnimationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.scale,
      currentAnimationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.scale,
      gameObject.animationController.value);

  Offset origin = Offset(size.width / 2, size.height / 2);
  
  canvas.save();
  
  canvas.translate(origin.dx, origin.dy);

  if (gameObject.animationPlaying) {
    canvas.translate(positionInterpolation.dx, positionInterpolation.dy);
    canvas.rotate(rotationInterpolation);
    canvas.scale(scaleInterpolation);
  } else {
    canvas.translate(
        currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].tweenData.position.dx,
        currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].tweenData.position.dy);
    canvas.rotate(currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].tweenData.rotation);
    canvas.scale(currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].tweenData.scale);
  }

  canvas.translate(-origin.dx, -origin.dy);

  // Draw sketches using a Path for smoother curves
  for (SketchModel sketch in currentAnimationTrack.keyFrames[gameObject.activeFrameIndex].sketches.data) {
    Paint paint = Paint()
      ..color = sketch.color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = sketch.strokeWidth;

    // Path path = Path();
    if (sketch.points.isNotEmpty) {
      // path.moveTo(sketch.points[0].dx, sketch.points[0].dy);
      for (int i = 0; i < sketch.points.length - 1; i++) {
        // Used quadratic bezier curve instead of the draw line function that made the line look jagged credit to JideGuru on youtube
        // if (i < sketch.points.length - 1) {
        //   Offset midPoint = Offset(
        //     (sketch.points[i].dx + sketch.points[i + 1].dx) / 2,
        //     (sketch.points[i].dy + sketch.points[i + 1].dy) / 2,
        //   );
        //   path.quadraticBezierTo(sketch.points[i].dx, sketch.points[i].dy, midPoint.dx, midPoint.dy);
        // }
        var currentPointX = sketch.points[i].dx / 4;
        var currentPointY = sketch.points[i].dy / 4;
        var nextPointX = sketch.points[i+1].dx / 4;
        var nextPointY = sketch.points[i+1].dy / 4;
        canvas.drawLine(Offset(currentPointX, currentPointY), Offset(nextPointX, nextPointY), paint);
      }
    }
    // canvas.drawPath(path, paint);
  }

  canvas.restore();
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}