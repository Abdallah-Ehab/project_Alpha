import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static late final AudioPlayer player;
  static final instance = AudioManager._internal();
  AudioManager._internal(){
    player = AudioPlayer();
  }

  void play(String path,ReleaseMode releaseMode, {bool loop = false})async {
    player.setReleaseMode(releaseMode);
    await player.play(AssetSource(path));
  }
}
