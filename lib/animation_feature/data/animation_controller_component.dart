import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';

class AnimationControllerComponent extends Component {
  int _currentFrame;
  bool animationPlaying;
  Duration lastUpdate;
   String _currentAnimationTrackName;
   List<Transition> transitions;
  Map<String, AnimationTrack> animationTracks;

  AnimationControllerComponent({
  bool? isActive,
  int? currentFrame,
  bool? animationPlaying,
  Duration? lastUpdate,
  String? currentAnimationTrackName,
  List<Transition>? transitions,
  Map<String, AnimationTrack>? animationTracks,
})  : _currentFrame = currentFrame ?? 0,
      animationPlaying = animationPlaying ?? false,
      lastUpdate = lastUpdate ?? Duration.zero,
      _currentAnimationTrackName = currentAnimationTrackName ?? "idle",
      transitions = transitions ?? [
        Transition(
          startTrackName: "idle",
          condition: Condition(entityVariable: "x", secondOperand: 0.5, operator: ">"),
          targetTrackName: "walk",
        ),
        Transition(
          startTrackName: "walk",
          condition: Condition(entityVariable: "x", secondOperand: 0.5, operator: "<"),
          targetTrackName: "idle",
        ),
      ],
      animationTracks = animationTracks ?? {
        "idle": AnimationTrack("idle", [KeyFrame(sketches: [])],true),
        "walk": AnimationTrack("walk",[KeyFrame(sketches: [])],false)
      },
      super(isActive: isActive ?? true);




  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'animation_controller',
      'isActive': isActive,
      'currentFrame': _currentFrame,
      'animationPlaying': animationPlaying,
      'lastUpdate': lastUpdate.inMilliseconds, // Save as milliseconds
      'currentAnimationTrackName': _currentAnimationTrackName,
      'transitions': transitions.map((t) => t.toJson()).toList(),
      'animationTracks': animationTracks.map((key, track) => MapEntry(key, track.toJson())),
    };
  }

  /// fromJson
  factory AnimationControllerComponent.fromJson(Map<String, dynamic> json) {
    return AnimationControllerComponent(
      isActive: json['isActive'] as bool? ?? true,
      currentFrame: json['currentFrame'] as int? ?? 0,
      animationPlaying: json['animationPlaying'] as bool? ?? true,
      lastUpdate: Duration(milliseconds: json['lastUpdate'] as int? ?? 0),
      currentAnimationTrackName: json['currentAnimationTrackName'] as String? ?? "idle",
      transitions: (json['transitions'] as List<dynamic>?)
          ?.map((e) => Transition.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      animationTracks: (json['animationTracks'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, AnimationTrack.fromJson(value as Map<String, dynamic>))) ??
          {},
    );
  }




  void addTrack(String name, {int fps = 10, AnimationTrack? track}) {
    if (track != null) {
      animationTracks[name] = track;
      notifyListeners();
      return;
    }
    animationTracks[name] = AnimationTrack(name, [], true,fps: fps);
    _currentAnimationTrackName = name;
    notifyListeners();
  }

  set currentFrame(int currentFrame) {
    _currentFrame = currentFrame;
    notifyListeners();
  }

  int get currentFrame => _currentFrame;

  AnimationTrack get currentAnimationTrack =>
      animationTracks[_currentAnimationTrackName]!;

  void setTrack(String name) {
    if (name == _currentAnimationTrackName) return;
    if (animationTracks.containsKey(name)) {
      _currentAnimationTrackName = name;
      currentFrame = 0;
      animationPlaying = true;
    }
    notifyListeners();
  }

  void addFramesToAnimationTracK(
      {required String trackName, required List<KeyFrame> frames}) {
    animationTracks[trackName]!.frames.addAll(frames);
    notifyListeners();
  }

  @override
  void update(Duration dt, {required Entity activeEntity}) {
    for (Transition transition in transitions) {
      transition.execute(activeEntity, this);
    }
    final track = animationTracks[_currentAnimationTrackName]!;
    final frameDuration = Duration(milliseconds: 1000 ~/ track.fps);
    if (dt - lastUpdate >= frameDuration) { // was (dt - lastUpdate >= frameDuration)
      _currentFrame = track.isLooping ? (_currentFrame + 1) % track.frames.length : (_currentFrame + 1).clamp(0, track.frames.length - 1);
      lastUpdate = dt;
    }
    notifyListeners();
  }
  
  @override
  void reset() {
    _currentFrame = 0;
    _currentAnimationTrackName = "idle";
    lastUpdate = Duration.zero;
    notifyListeners();
  }
  
  @override
  Component copy() {
    return AnimationControllerComponent(
    isActive: isActive,
    currentFrame: _currentFrame,
    animationPlaying: animationPlaying,
    lastUpdate: lastUpdate,
    currentAnimationTrackName: _currentAnimationTrackName,
    transitions: transitions.map((t) => t.copy()).toList(),
    animationTracks: animationTracks.map((k, v) => MapEntry(k, v.copy())),
  );
  }


}

class Transition {
  String startTrackName;
  Condition condition;
  String targetTrackName;
  Transition(
      {required this.startTrackName,
      required this.condition,
      required this.targetTrackName});

  Transition copy(){
    return Transition(
      startTrackName: startTrackName,
      condition: condition,
      targetTrackName: targetTrackName
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTrackName': startTrackName,
      'condition': condition.toJson(),
      'targetTrackName': targetTrackName,
    };
  }

  factory Transition.fromJson(Map<String, dynamic> json) {
    return Transition(
      startTrackName: json['startTrackName'] as String,
      condition: Condition.fromJson(json['condition'] as Map<String, dynamic>),
      targetTrackName: json['targetTrackName'] as String,
    );
  }


  void execute(Entity entity, AnimationControllerComponent animComponent) {
    if (condition.execute(entity)) {
      if (animComponent._currentAnimationTrackName == startTrackName) {
        animComponent.setTrack(targetTrackName);
      }
    }
  }
}

class Condition {
  String entityVariable;
  double secondOperand;
  String operator;
  Condition(
      {required this.entityVariable,
      required this.secondOperand,
      required this.operator});
  
  Condition copy(){
    return Condition(entityVariable: entityVariable, secondOperand: secondOperand, operator: operator);
  }
  Map<String, dynamic> toJson() {
    return {
      'entityVariable': entityVariable,
      'secondOperand': secondOperand,
      'operator': operator,
    };
  }

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      entityVariable: json['entityVariable'] as String,
      secondOperand: (json['secondOperand'] as num).toDouble(),
      operator: json['operator'] as String,
    );
  }
  bool execute(Entity entity) {
    if (entity.variables[entityVariable] == null) return false;
    switch (operator) {
      case "==":
        return entity.variables[entityVariable] == secondOperand;

      case ">":
        return entity.variables[entityVariable] > secondOperand;

      case "<":
        return entity.variables[entityVariable] < secondOperand;

      case ">=":
        return entity.variables[entityVariable] >= secondOperand;
      case "<=":
        return entity.variables[entityVariable] <= secondOperand;
      case "!=":
        return entity.variables[entityVariable] != secondOperand;
      default:
        return false;
    }
  }
}
