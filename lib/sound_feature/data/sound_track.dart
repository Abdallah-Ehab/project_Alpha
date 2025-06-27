// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';

class SoundTrack {
  final String name;
  final String filePath;
  final bool loop;
  final ReleaseMode releaseMode;

  SoundTrack({
    required this.name,
    required this.filePath,
    required this.loop,
    required this.releaseMode,
  });
}
