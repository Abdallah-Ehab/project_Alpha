import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static late final AudioPlayer player;
  static final instance = AudioManager._internal();
  AudioManager._internal(){
    player = AudioPlayer();
  }

  Future<void> playAsset(String assetPath, ReleaseMode releaseMode, {bool loop = false}) async {
  await player.setVolume(1.0); // Ensure volume
  await player.setReleaseMode(releaseMode);
  await player.play(AssetSource(assetPath));
}

void playFile(String filePath, ReleaseMode releaseMode, {bool loop = false}) async {
  player.setReleaseMode(releaseMode);
  await player.play(DeviceFileSource(filePath));
}

void playBytes(Uint8List data, ReleaseMode releaseMode, {bool loop = false}) async {
  player.setReleaseMode(releaseMode);
  await player.play(BytesSource(data));
}

}
