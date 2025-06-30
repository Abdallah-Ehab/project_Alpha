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
   
    this.currentlyPlaying,
    super.isActive,
  }): tracks = {},transitions = [];

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

  

  void play(String trackName) {
    if (trackName == currentlyPlaying) return;
    final track = tracks[trackName];
    if (track == null) return;

    // trigger playback (delegate to audio manager)
    AudioManager.instance.play(track.filePath,track.releaseMode, loop: track.loop);
    currentlyPlaying = trackName;
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
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
