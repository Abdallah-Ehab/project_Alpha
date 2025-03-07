import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/animationModels/animation_track.dart';
import 'package:scratch_clone/models/animationModels/key_frame_model.dart';
import 'package:scratch_clone/models/animationModels/sketch_model.dart';
import 'package:scratch_clone/providers/animationProviders/animation_controller_provider.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/animationWidgets/animation_tracks_drop_down_menu.dart';
import '../../constants/colors/colors.dart';

class TimeLineWidget extends StatefulWidget {
  const TimeLineWidget({super.key});

  @override
  State<TimeLineWidget> createState() => _TimeLineWidgetState();
}

class _TimeLineWidgetState extends State<TimeLineWidget> {
  late PageController _pageController;
  late TextEditingController _textController;
  late TextEditingController _addAnimationTrackController;

  @override
  void initState() {
    _pageController = PageController();
    _textController = TextEditingController();
    _addAnimationTrackController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    _addAnimationTrackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var framesProvider = Provider.of<FramesProvider>(context);
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    var animationControllerProvider = Provider.of<AnimationControllerProvider>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: MyColors.deepBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        height: 200,
        child: Column(
          children: [
            // 🎬 Animation Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimationTracksDropDownMenu(),

                _buildCircleButton(
                  icon: Icons.skip_previous,
                  onTap: () {
                    if (framesProvider.activeFrameIndex > 0) {
                      framesProvider.activeFrameIndex--;
                    }
                  },
                ),

                _buildPlayButton(animationControllerProvider, gameObjectProvider),

                _buildCircleButton(
                  icon: Icons.skip_next,
                  onTap: () {
                    if (framesProvider.activeFrameIndex <
                        gameObjectProvider.currentGameObject.animationTracks[
                            gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length) {
                      framesProvider.activeFrameIndex++;
                    }
                  },
                ),

                _buildCircleButton(
                  icon: Icons.add_circle_rounded,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _buildAddAnimationTrackDialog(context, gameObjectProvider);
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 📜 Timeline Frames
            SizedBox(
              height: 100,
              child: PageView.builder(
                controller: _pageController,
                itemCount: gameObjectProvider
                        .currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length +
                    1,
                scrollDirection: Axis.horizontal,
                onPageChanged: (value) {
                  if (value <=
                      gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length -
                          1) {
                    framesProvider.activeFrameIndex = value;
                  }
                },
                itemBuilder: (context, index) {
                  var track = gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!;
                  return _buildFrameTile(context, index, track, framesProvider, gameObjectProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: MyColors.deepBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: MyColors.pastelPeach,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPlayButton(AnimationControllerProvider animationControllerProvider, GameObjectManagerProvider gameObjectProvider) {
    return GestureDetector(
      onTap: () {
        animationControllerProvider.isPlaying = !animationControllerProvider.isPlaying;
        playAnimation(context, gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!);
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: MyColors.deepBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: animationControllerProvider.isPlaying
                  ? MyColors.pastelPeach.withOpacity(0.6)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          animationControllerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
          color: MyColors.pastelPeach,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildFrameTile(BuildContext context, int index, AnimationTrack track, FramesProvider framesProvider, GameObjectManagerProvider gameObjectProvider) {

    if (index < gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length) {
                    if (gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[index].frameType ==
                        KeyFrameType.fullKey) {
                      return Container(
                        margin: const EdgeInsets.all(10),
                        width: 50,
                        height: 100,
                        color: Colors.blue,
                        child: Center(child: Text("$index")),
                      );
                    }
                  }
                  return GestureDetector(
                    onTap: () {
                      if(index > gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length - 1){
                        gameObjectProvider.addFrameToAnimationTrack(KeyframeModel(
                              FrameByFrameKeyFrame(data: []),
                              index,
                              TweenKeyFrame(
                                  position: const Offset(0, 0),
                                  scale: 1.0,
                                  rotation: 0.0),
                              KeyFrameType.fullKey));
                              framesProvider.activeFrameIndex = index;
                          
                      }else{
                        gameObjectProvider.addInbetweenFrameToAnimationTrack(index,KeyframeModel(
                              FrameByFrameKeyFrame(data: []),
                              index,
                              TweenKeyFrame(
                                  position: const Offset(0, 0),
                                  scale: 1.0,
                                  rotation: 0.0),
                              KeyFrameType.fullKey));
                      }
                      gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.addToFullKeyFrameIndices(index);
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                                "choose the number of frames to insert"),
                            content: TextField(
                              controller: _textController,
                              decoration:
                                  const InputDecoration(hintText: "no of frames"),
                              keyboardType: TextInputType.number,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  List<SketchModel> temp = gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[framesProvider.activeFrameIndex].frameByFrameKeyFrame.data;
                                  int numberOfinsertedFrames =
                                      int.parse(_textController.text);
                                  for (int i = 0;
                                      i < numberOfinsertedFrames;
                                      i++) {
                                    gameObjectProvider.addFrameToAnimationTrack(
                                        KeyframeModel(
                                            FrameByFrameKeyFrame(data: temp),
                                            index,
                                            TweenKeyFrame(
                                                position: const Offset(0, 0),
                                                scale: 1.0,
                                                rotation: 0.0),
                                            KeyFrameType.blankKey));
                                  }
                                  
                                  gameObjectProvider.addFrameToAnimationTrack(
                                      KeyframeModel(
                                          FrameByFrameKeyFrame(data: []),
                                          index,
                                          TweenKeyFrame(
                                              position: const Offset(0, 0),
                                              scale: 1.0,
                                              rotation: 0.0),
                                          KeyFrameType.fullKey));
                                  framesProvider.activeFrameIndex +=
                                      numberOfinsertedFrames+1;
                                  gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[framesProvider.activeFrameIndex].frameByFrameKeyFrame.data = temp;
                                  gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.addToFullKeyFrameIndices(index);
                                },
                                child: const Text("insert"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("cancel"),
                              )
                            ],
                          );
                        },
                      );
                    
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
  }

  Widget _buildAddAnimationTrackDialog(BuildContext context, GameObjectManagerProvider gameObjectProvider) {
    return AlertDialog(
      backgroundColor: MyColors.deepBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: TextField(
        controller: _addAnimationTrackController,
        decoration: InputDecoration(
          hintText: "Enter animation track name",
          hintStyle: TextStyle(color: MyColors.coolGray),
          filled: true,
          fillColor: MyColors.babyBlue.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_addAnimationTrackController.text.isEmpty) return;
            gameObjectProvider.addNewAnimationTrack(_addAnimationTrackController.text);
            Navigator.of(context).pop();
          },
          child: Text("Apply", style: TextStyle(color: MyColors.pastelPeach)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void playAnimation(BuildContext context, AnimationTrack track) {
    var animationController = Provider.of<AnimationControllerProvider>(context, listen: false);
    if (track.keyFrames.isEmpty) return;

    int durationInSeconds = (track.keyFrames.length / 12).ceil();
    animationController.setDuration(durationInSeconds);

    animationController.controller.reset();
    animationController.controller.forward();
    animationController.controller.addListener(() {
      var framesProvider = Provider.of<FramesProvider>(context, listen: false);
      int frameIndex = (animationController.progress * (track.keyFrames.length - 1)).round();
      if (frameIndex < track.keyFrames.length) framesProvider.activeFrameIndex = frameIndex;
    });
  }
}
