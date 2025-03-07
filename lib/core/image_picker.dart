
import 'dart:developer';

import 'package:image_picker/image_picker.dart';



import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

class MYImagePicker {
  static final MYImagePicker _instance = MYImagePicker._();

  MYImagePicker._();

  static MYImagePicker getInstance() => _instance;

  Future<List<ui.Image>?> pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile?> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        List<ui.Image> uiImages = [];
        for (var file in images) {
          if (file != null) {
            ui.Image? image = await _loadImage(File(file.path));
            if (image != null) {
              uiImages.add(image);
            }
          }
        }
        return uiImages;
      }
    } catch (e) {
      log("Error picking images: $e");
    }
    return null;
  }

  Future<ui.Image?> _loadImage(File file) async {
    try {
      Uint8List bytes = await file.readAsBytes();
      ui.Codec codec = await ui.instantiateImageCodec(bytes);
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      log("Error loading image: $e");
      return null;
    }
  }
}
