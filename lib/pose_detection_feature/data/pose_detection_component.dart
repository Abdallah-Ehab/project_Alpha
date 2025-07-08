// import 'package:scratch_clone/component/component.dart';
// import 'package:scratch_clone/entity/data/entity.dart';
// import 'package:scratch_clone/entity/data/entity_manager.dart';

// class PoseDetectionComponent extends Component {
//   final String targetEntityName;
//   final String variableName;
//   final Map<String, dynamic> poseMappings;
//   final int updateIntervalMs;
//   final dynamic defaultValue;
//   final bool autoReset;

//   DateTime _lastUpdate = DateTime.now();

//   PoseDetectionComponent({
//     required this.targetEntityName,
//     required this.variableName,
//     required this.poseMappings,
//     this.updateIntervalMs = 300,
//     this.defaultValue,
//     this.autoReset = true,
//   });

//   @override
//   void update(Duration dt, {required Entity activeEntity}) async {
//     final now = DateTime.now();
//     if (now.difference(_lastUpdate).inMilliseconds < updateIntervalMs) return;
//     _lastUpdate = now;

//     final detectedPose = await runPoseDetection();

//     final valueToSet = poseMappings[detectedPose] ?? defaultValue;

//     final entity = EntityManager().getActorByName(targetEntityName);
//     if (entity != null) {
//       entity.setVariableXToValueY(variableName, valueToSet);
//     }
//   }

//   Future<String> runPoseDetection() async {
    
//   }

//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'type': 'PoseDetectionComponent',
//       'targetEntityName': targetEntityName,
//       'variableName': variableName,
//       'poseMappings': poseMappings,
//       'updateIntervalMs': updateIntervalMs,
//       'defaultValue': defaultValue,
//       'autoReset': autoReset,
//     };
//   }

//   static PoseDetectionComponent fromJson(Map<String, dynamic> json) {
//     return PoseDetectionComponent(
//       targetEntityName: json['targetEntityName'],
//       variableName: json['variableName'],
//       poseMappings: Map<String, dynamic>.from(json['poseMappings']),
//       updateIntervalMs: json['updateIntervalMs'] ?? 300,
//       defaultValue: json['defaultValue'],
//       autoReset: json['autoReset'] ?? true,
//     );
//   }

//   @override
//   Component copy() => fromJson(toJson());
  
//   @override
//   void reset() {
    
//   }
// }
