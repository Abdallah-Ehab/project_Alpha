import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;

class ImageLoader {
  static Future<List<ui.Image>> loadImages(
      {required String animationName,
      required String character,
      required int animationLength}) async {
    List<ui.Image> frames = [];
    for (int i = 0; i < animationLength; i++) {
      var currentImage = await _getUiImage(
          "assets/$character/$animationName/tile00$i.png", 140, 140);
      frames.add(currentImage);
    }
    return frames;
  }

  static Future<ui.Image> _getUiImage(
      String path, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(path);
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    if (baseSizeImage == null) throw Exception("Failed to decode image");
    image.Image resizedImage =
        image.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizedImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
