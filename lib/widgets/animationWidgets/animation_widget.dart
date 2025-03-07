// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/functions.dart';

import 'package:scratch_clone/models/animationModels/animation_track.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';

import 'package:scratch_clone/providers/animationProviders/animation_controller_provider.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';

// this code is used for :
//1- enablling the user to draw and adding each drawing to a list of sketches
//2- adding the list of sketches to the current frame
//3- use custompainter to draw the current frame
//4- use custompainter to draw the current frame drawing in the position of the tween
class Animationwidget extends StatelessWidget {
  const Animationwidget({super.key});

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);
    var frameProvider = Provider.of<FramesProvider>(context);
    var animationControllerProvider =
        Provider.of<AnimationControllerProvider>(context);
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: GestureDetector(
                onPanStart: (details) {
                  log('${details.localPosition}');
                  sketchProvider.currentSketch = SketchModel(
                      sketchMode: sketchProvider.currentsketchMode,
                      points: [details.localPosition],
                      color: sketchProvider.currentColor,
                      strokeWidth: sketchProvider.currentStrokeWidth);
                  if (sketchProvider.currentSketch.sketchMode ==
                      SketchMode.eraser) {
                    return;
                  }
                  gameObjectProvider
                      .addCurrentSketchToCurrentFrameInSelectedAnimationTrack(
                          frameProvider.activeFrameIndex,
                          sketchProvider.currentSketch);
                },
                onPanUpdate: (details) {
                  var numberOfsketches = gameObjectProvider
                      .currentGameObject
                      .animationTracks[
                          gameObjectProvider.selectedAnimationTrack.name]!
                      .keyFrames[frameProvider.activeFrameIndex]
                      .frameByFrameKeyFrame
                      .data
                      .length;
                  if (sketchProvider.currentSketch.sketchMode ==
                      SketchMode.eraser) {
                    for (int i = 0; i < numberOfsketches; i++) {
                      log("Before erasing from frame ${frameProvider.activeFrameIndex}: ${gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[frameProvider.activeFrameIndex].frameByFrameKeyFrame.data[i].points.length}");
                      gameObjectProvider.removePoints(details.localPosition, i,
                          sketchProvider.currentStrokeWidth,frameProvider.activeFrameIndex);
                      log("After erasing from frame ${frameProvider.activeFrameIndex}: ${gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[frameProvider.activeFrameIndex].frameByFrameKeyFrame.data[i].points.length}");
                      
                    }
                  } else {
                    sketchProvider.addPoint(details.localPosition);
                    gameObjectProvider.addPointToTheLastSketchInTheFrame(
                        frameProvider.activeFrameIndex, details.localPosition);
                  }
                },
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height * 0.6),
                  painter: AnimationPainter(
                      activeFrameIndex: frameProvider.activeFrameIndex,
                      animationTrack:
                          gameObjectProvider.currentGameObject.animationTracks[
                              gameObjectProvider.selectedAnimationTrack.name]!,
                      progress: animationControllerProvider.progress,
                      controllerProvider: animationControllerProvider,
                      fullKeyFrameIndices: gameObjectProvider
                          .currentGameObject
                          .animationTracks[
                              gameObjectProvider.selectedAnimationTrack.name]!
                          .fullKeyFramesIndices),
                )),
          ),
        ),
      ],
    );
  }
}

class AnimationPainter extends CustomPainter {
  AnimationTrack animationTrack;
  double progress;
  int activeFrameIndex;
  AnimationControllerProvider controllerProvider;
  List<int> fullKeyFrameIndices;
  AnimationPainter({
    required this.animationTrack,
    required this.progress,
    required this.activeFrameIndex,
    required this.controllerProvider,
    required this.fullKeyFrameIndices,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3); // Light grey for visibility
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
        
    if (animationTrack.keyFrames.isEmpty ||
        (animationTrack.keyFrames[activeFrameIndex].frameByFrameKeyFrame.data.isEmpty && animationTrack.keyFrames[activeFrameIndex].frameByFrameKeyFrame.image == null)) {
      return;
    }
    


    int previousFrameIndex =
        ((fullKeyFrameIndices.length - 1) * progress).floor();
    int nextFrameIndex = ((fullKeyFrameIndices.length - 1) * progress).ceil();

    // Ensure valid indices
    previousFrameIndex =
        previousFrameIndex.clamp(0, fullKeyFrameIndices.length - 1);
    nextFrameIndex = nextFrameIndex.clamp(0, fullKeyFrameIndices.length - 1);

    int previousFullKeyFrameIndex = fullKeyFrameIndices[previousFrameIndex];
    int nextFullKeyFrameIndex = fullKeyFrameIndices[nextFrameIndex];
    // Interpolated values
    Offset positionInterpolation = lerpOffset(
        animationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.position,
        animationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.position,
        progress);
    double rotationInterpolation = lerpDouble(
        animationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.rotation,
        animationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.rotation,
        progress);
    double scaleInterpolation = lerpDouble(
        animationTrack.keyFrames[previousFullKeyFrameIndex].tweenData.scale,
        animationTrack.keyFrames[nextFullKeyFrameIndex].tweenData.scale,
        progress);

    // Set a custom origin (center of the frame may be later I will find a way to make it the center of the sketch it self)
    Offset origin = Offset(size.width / 2, size.height / 2);

    canvas.save();

    // Move to the new origin
    canvas.translate(origin.dx, origin.dy);

    if (controllerProvider.isPlaying) {
      canvas.translate(positionInterpolation.dx, positionInterpolation.dy);
      canvas.rotate(rotationInterpolation);
      canvas.scale(scaleInterpolation);
    } else {
      canvas.translate(
          animationTrack.keyFrames[activeFrameIndex].tweenData.position.dx,
          animationTrack.keyFrames[activeFrameIndex].tweenData.position.dy);
      canvas.rotate(
          animationTrack.keyFrames[activeFrameIndex].tweenData.rotation);
      canvas.scale(animationTrack.keyFrames[activeFrameIndex].tweenData.scale);
    }

    // Translate back so sketches are drawn at the correct position
    canvas.translate(-origin.dx, -origin.dy);
    //  Path path = Path();
     if(animationTrack.keyFrames[activeFrameIndex].frameByFrameKeyFrame.image != null){
      var currentImage = animationTrack.keyFrames[activeFrameIndex].frameByFrameKeyFrame.image!;
      paintImage(canvas: canvas, rect: Rect.fromLTRB(0, 0, size.width, size.height), image: currentImage);
    }
    // Draw sketches
    for (SketchModel sketch
        in animationTrack.keyFrames[activeFrameIndex].frameByFrameKeyFrame.data) {
      // path.moveTo(sketch.points[0].dx, sketch.points[0].dy);
      Paint paint = Paint()
        ..color = sketch.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = sketch.strokeWidth;

      for (int i = 0; i < sketch.points.length - 1; i++) {
        // if (i < sketch.points.length - 1) {
        //     Offset midPoint = Offset(
        //       (sketch.points[i].dx + sketch.points[i+1].dx) / 2,
        //       (sketch.points[i].dy + sketch.points[i+1].dy) / 2,
        //     );
        //     path.quadraticBezierTo(sketch.points[i].dx, sketch.points[i].dy, midPoint.dx, midPoint.dy);
        //   }
        canvas.drawLine(sketch.points[i], sketch.points[i + 1], paint);
      }
      // canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
