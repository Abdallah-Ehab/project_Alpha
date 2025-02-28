import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/animationModels/animation_track.dart';
import 'package:scratch_clone/models/animationModels/key_frame_model.dart';

import 'package:scratch_clone/models/animationModels/sketch_model.dart';

import 'package:scratch_clone/providers/animationProviders/animation_controller_provider.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/animationWidgets/animation_tracks_drop_down_menu.dart';





// this class is for the time line in the animation editor
// the animation editor depends on the current gameObject and the selected animation track in the currentgameObject
// most of the animation editor variables are global like the active frame index and the animationcontroller
//since you will always mostly run one animation with one progress rate fps etc...
// the fullkeyframe indices are also tracked in the animationtrack in the game object and not separately as it was the case

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
    super.dispose();
    _pageController.dispose();
    _textController.dispose();
    _addAnimationTrackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var framesProvider = Provider.of<FramesProvider>(context);
    var gameObjectProvider = Provider.of<GameObjectManagerProvider>(context);
    var animationControllerProvider = Provider.of<AnimationControllerProvider>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimationTracksDropDownMenu(),
                IconButton(
                  onPressed: () {
                    if (framesProvider.activeFrameIndex > 0) {
                      framesProvider.activeFrameIndex--;
                    }
                  },
                  icon: const Icon(Icons.skip_previous),
                ),
                IconButton(
                  onPressed: () {
                    if (framesProvider.activeFrameIndex <
                        gameObjectProvider
                            .currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length) {
                      framesProvider.activeFrameIndex++;
                    }
                  },
                  icon: const Icon(Icons.skip_next),
                ),
                IconButton(
                  onPressed: () {
                    animationControllerProvider.isPlaying = !animationControllerProvider.isPlaying;
                    AnimationTrack animationTrack =
                        gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!;
      
                    playAnimation(context, animationTrack);
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
                IconButton(onPressed: (){
                  showDialog(context: context, builder: (context){
                    return AlertDialog(
                      content: TextField(
                        controller: _addAnimationTrackController,
                        decoration: const InputDecoration(
                          hintText: "enter the animation track name"
                        ),
                      ),

                      actions: [
                        TextButton(onPressed: (){
                          if(_addAnimationTrackController.text.isEmpty) return;
                          gameObjectProvider.addNewAnimationTrack(_addAnimationTrackController.text);
                          Navigator.of(context).pop();
                        }, child: const Text("apply")),
                        TextButton(onPressed: (){
                          Navigator.of(context).pop();
                        },child: const Text("cancel"))
                      ],
                    );
                  });
                }, icon: const Icon(Icons.add_circle_rounded,color: Colors.black,))
              ],
            ),
            SizedBox(
              height: 100,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  if (value <=
                      gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length -
                          1) {
                    framesProvider.activeFrameIndex = value;
                  }
                },
                itemCount:
                    gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length +
                        1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index <
                      gameObjectProvider
                          .currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames.length) {
                    if (gameObjectProvider
                            .currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[index].frameType ==
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
                                  List<SketchModel> temp = gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[framesProvider.activeFrameIndex].sketches.data;
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
                                  gameObjectProvider.currentGameObject.animationTracks[gameObjectProvider.selectedAnimationTrack.name]!.keyFrames[framesProvider.activeFrameIndex].sketches.data = temp;
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 void playAnimation(BuildContext context, AnimationTrack track) {
  var animationController = Provider.of<AnimationControllerProvider>(context, listen: false);

  if (track.keyFrames.isEmpty) return;

  int durationInSeconds = (track.keyFrames.length / 12).ceil();
  animationController.setDuration(durationInSeconds);

  animationController.controller.reset();
  animationController.controller.forward();

  // Remove previous listeners
  animationController.controller.removeStatusListener(_animationStatusListener);

  // Add status listener to detect when animation finishes
  animationController.controller.addStatusListener(_animationStatusListener);

  animationController.controller.removeListener(()=>_frameUpdateListener(track: track));
  animationController.controller.addListener(()=>_frameUpdateListener(track: track));
}


void _frameUpdateListener({required AnimationTrack track}) {
  var animationController = Provider.of<AnimationControllerProvider>(context, listen: false);
  var framesProvider = Provider.of<FramesProvider>(context, listen: false);
  
  int frameIndex = (animationController.progress * (track.keyFrames.length - 1)).round();

  if (frameIndex < track.keyFrames.length) {
    framesProvider.activeFrameIndex = frameIndex;
  }
}

// Status listener function
void _animationStatusListener(AnimationStatus status) {
  var animationController = Provider.of<AnimationControllerProvider>(context, listen: false);
  var framesProvider = Provider.of<FramesProvider>(context,listen: false);
  if (status == AnimationStatus.completed) {
    animationController.isPlaying = false;
    framesProvider.activeFrameIndex = 0;
  }
}
}