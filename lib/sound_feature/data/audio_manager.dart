
import 'dart:developer';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static late final AudioPlayer player;
  static final instance = AudioManager._internal();

  AudioManager._internal() {
    player = AudioPlayer();
    // Add state listeners for debugging
    player.onPlayerStateChanged.listen((state) {
      log("Player state changed: $state");
    });
  }

  Future<void> playAsset(String assetPath, ReleaseMode releaseMode,
      {bool loop = false}) async {
    try {
      await player.setVolume(1.0);
      await player.setReleaseMode(releaseMode);

      await player.play(AssetSource(assetPath));
      log("Playing asset: $assetPath");
    } catch (e) {
      log("Error in playAsset: $e");
      rethrow;
    }
  }

  void playFile(String filePath, ReleaseMode releaseMode,
      {bool loop = false}) async {
    player.setReleaseMode(releaseMode);
    await player.play(DeviceFileSource(filePath));
  }

   Future<void> stop() async {
    try {
      await player.stop();
      log("Audio stopped");
    } catch (e) {
      log("Error stopping audio: $e");
      rethrow;
    }
  }

  void playBytes(Uint8List data, ReleaseMode releaseMode,
      {bool loop = false}) async {
    player.setReleaseMode(releaseMode);
    await player.play(BytesSource(data));
  }
}
