
import 'dart:developer';

import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/sound_feature/data/audio_manager.dart';
import 'package:scratch_clone/sound_feature/data/sound_track.dart';

class SoundControllerComponent extends Component {
  Map<String, SoundTrack> tracks;
  String? currentlyPlaying;
  List<Transition> transitions;

  SoundControllerComponent({
   
    this.currentlyPlaying = '',
    super.isActive,
  }): tracks = {},transitions = [
    Transition(startTrackName: 'breath', condition: Condition(entityVariable: 'breath', secondOperand: 'true', operator: '=='), targetTrackName: 'boost'),
    Transition(startTrackName: 'boost', condition: Condition(entityVariable: 'breath', secondOperand: 'true', operator: '=='), targetTrackName: 'breath')
  ];

  @override
  void update(Duration dt, {required Entity activeEntity}) {
    for (final transition in transitions) {
      transition.execute(activeEntity,soundComponent: this);
    }
  }

  void removeTransitionAtIndex(int index){
    transitions.removeAt(index);
    notifyListeners();
  }

  void addTrack(String name, SoundTrack track){
    tracks[name] = track;
    notifyListeners();
  }

  void setTrack(String trackName){
    if (trackName == currentlyPlaying) return;
    final track = tracks[trackName];
    if (track == null) return;
    currentlyPlaying = trackName;
    notifyListeners();
  }
  

  void play(String trackName) async {
  if (trackName == currentlyPlaying) return;
  final track = tracks[trackName];
  if (track == null) {
    log("Track not found: $trackName");
    return;
  }

  try {
    await AudioManager.instance.stop();
    await AudioManager.instance.playAsset(track.filePath, track.releaseMode, loop: track.loop);
    currentlyPlaying = trackName;
    notifyListeners();
    log("Successfully playing: $trackName");
  } catch (e) {
    log("Error playing track $trackName: $e");
  }
}

  @override
  void reset() {
    currentlyPlaying = null;
  }

  @override
  Component copy() {
    return SoundControllerComponent(
      currentlyPlaying: currentlyPlaying,
      isActive: isActive,
    )..transitions = transitions.map((t) => t.copy()).toList()
    ..tracks = Map.from(tracks);
  }

  void addTransition(Transition transition){
    transitions.add(transition);
    notifyListeners();
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
