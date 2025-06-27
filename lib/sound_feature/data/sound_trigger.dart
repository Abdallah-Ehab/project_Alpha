import 'package:scratch_clone/entity/data/entity.dart';

class SoundTrigger {
  final String conditionVariable;
  final dynamic expectedValue;
  final String targetTrack;

  SoundTrigger({
    required this.conditionVariable,
    required this.expectedValue,
    required this.targetTrack,
  });

  bool evaluate(Entity entity) {
    return entity.variables[conditionVariable] == expectedValue;
  }

  SoundTrigger copy() => SoundTrigger(
    conditionVariable: conditionVariable,
    expectedValue: expectedValue,
    targetTrack: targetTrack,
  );
}
