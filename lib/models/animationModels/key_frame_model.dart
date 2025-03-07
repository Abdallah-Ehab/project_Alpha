// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui' as ui;

import 'package:scratch_clone/models/animationModels/sketch_model.dart';



enum KeyFrameType{
  blankKey,
  fullKey
}
class KeyframeModel {

  int frameNumber;
  FrameByFrameKeyFrame frameByFrameKeyFrame;
  TweenKeyFrame tweenData;
  KeyFrameType frameType;
  
  KeyframeModel( this.frameByFrameKeyFrame,this.frameNumber,this.tweenData,this.frameType);
}

class FrameByFrameKeyFrame {
  List<SketchModel> data;
  ui.Image? image;
  FrameByFrameKeyFrame({
    required this.data,
    this.image
  });
}

class TweenKeyFrame {
  

  ui.Offset position;
  double rotation;
  double scale;
  
  TweenKeyFrame({
   
 
    required this.position,
    required this.rotation,
    required this.scale,
  });


  
  
}

