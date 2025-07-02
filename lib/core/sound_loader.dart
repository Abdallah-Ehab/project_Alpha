import 'package:flutter/services.dart';

class SoundLoader {
  static Future<Uint8List> loadSoundAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }
}
