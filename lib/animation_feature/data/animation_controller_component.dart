import 'package:scratch_clone/animation_feature/data/animation_track.dart';
import 'package:scratch_clone/component/component.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/sound_feature/data/sound_controller_component.dart';

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
        transitions = transitions ??[],
        animationTracks = animationTracks ??{'idle':AnimationTrack('idle',[KeyFrame(sketches: [])],true,false)},
        super(isActive: isActive ?? true);

  void setFrame(int index) {
    if (index >= 0 && index < currentAnimationTrack.frames.length) {
      currentFrame = index;
      notifyListeners();
    }
  }

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
      'animationTracks':
          animationTracks.map((key, track) => MapEntry(key, track.toJson())),
    };
  }

  /// fromJson
  factory AnimationControllerComponent.fromJson(Map<String, dynamic> json) {
    return AnimationControllerComponent(
      isActive: json['isActive'] as bool? ?? true,
      currentFrame: json['currentFrame'] as int? ?? 0,
      animationPlaying: json['animationPlaying'] as bool? ?? true,
      lastUpdate: Duration(milliseconds: json['lastUpdate'] as int? ?? 0),
      currentAnimationTrackName:
          json['currentAnimationTrackName'] as String? ?? "idle",
      transitions: (json['transitions'] as List<dynamic>?)
              ?.map((e) => Transition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      animationTracks: (json['animationTracks'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key,
                  AnimationTrack.fromJson(value as Map<String, dynamic>))) ??
          {},
    );
  }

  void addTransition(Transition transition) {
    transitions.add(transition);
    notifyListeners();
  }

  void removeTransitionAtIndex(int index) {
    transitions.removeAt(index);
    notifyListeners();
  }

  void addTrack(String name, {int fps = 10, AnimationTrack? track}) {
    if (track != null) {
      animationTracks[name] = track;
      notifyListeners();
      return;
    }
    animationTracks[name] = AnimationTrack(name, [], true, false, fps: fps);
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
      transition.execute(activeEntity, animComponent: this);
    }
    final track = animationTracks[_currentAnimationTrackName]!;
    final frameDuration = Duration(milliseconds: 1000 ~/ track.fps);
    if (dt - lastUpdate >= frameDuration) {
      // was (dt - lastUpdate >= frameDuration)
      _currentFrame = track.isLooping
          ? (_currentFrame + 1) % track.frames.length
          : (_currentFrame + 1).clamp(0, track.frames.length - 1);
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


  void markAsDestroyAnimation(String trackName) {
    if (!animationTracks.containsKey(trackName)) return;
    
    // First, remove any existing destroy animation
    _removeExistingDestroyAnimationTransitions();
    
    // Mark the track as destroy animation
    animationTracks[trackName]!.setIsDestroyAnimationTrack(true);
    
    // Generate transitions from all other tracks to this destroy animation
    _generateDestroyAnimationTransitions(trackName);
    
    notifyListeners();
  }

  // NEW: Method to unmark an animation track as destroy animation
  void unmarkAsDestroyAnimation(String trackName) {
    if (!animationTracks.containsKey(trackName)) return;
    
    // Unmark the track
    animationTracks[trackName]!.setIsDestroyAnimationTrack(false);
    
    // Remove all destroy animation transitions
    _removeExistingDestroyAnimationTransitions();
    
    notifyListeners();
  }

  // NEW: Generate transitions from all other tracks to destroy animation
  void _generateDestroyAnimationTransitions(String destroyTrackName) {
    for (String trackName in animationTracks.keys) {
      if (trackName != destroyTrackName) {
        // Create transition from this track to destroy animation
        final destroyTransition = Transition(
          startTrackName: trackName,
          condition: Condition(
            entityVariable: "destroy",
            secondOperand: "true",
            operator: "=="
          ),
          targetTrackName: destroyTrackName,
        );
        
        transitions.add(destroyTransition);
      }
    }
  }

  // NEW: Remove existing destroy animation transitions
  void _removeExistingDestroyAnimationTransitions() {
    transitions.removeWhere((transition) {
      return transition.condition.entityVariable == "destroy" &&
             transition.condition.operator == "==" &&
             transition.condition.secondOperand == "true";
    });
  }

  // NEW: Get the current destroy animation track (if any)
  AnimationTrack? getDestroyAnimationTrack() {
    for (AnimationTrack track in animationTracks.values) {
      if (track.isDestroyAnimationTrack) {
        return track;
      }
    }
    return null;
  }

  // NEW: Check if there's a destroy animation track
  bool hasDestroyAnimation() {
    return getDestroyAnimationTrack() != null;
  }

  // NEW: Trigger destroy animation by setting entity variable
  void triggerDestroy(Entity entity) {
    entity.variables["destroy"] = true;
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

  Transition copy() {
    return Transition(
        startTrackName: startTrackName,
        condition: condition,
        targetTrackName: targetTrackName);
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

  void execute(Entity entity,
      {AnimationControllerComponent? animComponent,
      SoundControllerComponent? soundComponent}) {
    if (animComponent != null) {
      if (condition.execute(entity)) {
        if (animComponent._currentAnimationTrackName == startTrackName &&
            !animComponent.currentAnimationTrack.mustFinish) {
          animComponent.setTrack(targetTrackName);
        }
      }
    } else {
      if (condition.execute(entity)) {
        if (soundComponent!.currentlyPlaying == startTrackName) {
          soundComponent.play(targetTrackName);
        }
      }
    }
  }
}

class Condition {
  String entityVariable;
  String secondOperand;
  String operator;
  Condition(
      {required this.entityVariable,
      required this.secondOperand,
      required this.operator});

  Condition copy() {
    return Condition(
        entityVariable: entityVariable,
        secondOperand: secondOperand,
        operator: operator);
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
      secondOperand: json['secondOperand'],
      operator: json['operator'] as String,
    );
  }
  bool execute(Entity entity) {
    if (entity.variables[entityVariable] == null) return false;
    final secondOp = _parseValue(secondOperand);
    switch (operator) {
      case "==":
        return entity.variables[entityVariable] == secondOp;

      case ">":
        return entity.variables[entityVariable] > secondOp;

      case "<":
        return entity.variables[entityVariable] < secondOp;

      case ">=":
        return entity.variables[entityVariable] >= secondOp;
      case "<=":
        return entity.variables[entityVariable] <= secondOp;
      case "!=":
        return entity.variables[entityVariable] != secondOp;
      default:
        return false;
    }
  }

  dynamic _parseValue(dynamic val) {
    if (val is bool) return val;
    if (val is String) {
      final lower = val.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
      final numVal = double.tryParse(val);
      if (numVal != null) return numVal;
      return val;
    }
    if (val is num) return val;
    return val;
  }
}
