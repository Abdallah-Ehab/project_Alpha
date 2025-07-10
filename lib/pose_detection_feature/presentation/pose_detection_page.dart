// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:scratch_clone/entity/data/entity.dart';
// import 'package:scratch_clone/entity/data/entity_manager.dart';
// import 'package:scratch_clone/pose_detection_feature/data/pose_detection_component.dart';

// class PoseDetectionPage extends StatelessWidget {
//   const PoseDetectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final activeEntity = context.read<EntityManager>().activeEntity;
//     final poseComponent = activeEntity?.getComponent<PoseDetectionComponent>();

//     if (activeEntity == null || poseComponent == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Pose Detection")),
//         body: const Center(child: Text("No Pose Detection Component found.")),
//       );
//     }

//     return ChangeNotifierProvider.value(
//       value: activeEntity,
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Pose Detection")),
//         body: Consumer<Entity>(
//           builder: (_, entity, __) {
//             final component = entity.getComponent<PoseDetectionComponent>()!;
//             final mappings = component.poseMappings;

//             return ChangeNotifierProvider.value(
//               value: component,
//               child: Consumer<PoseDetectionComponent>(
//                 builder: (context, component, child) =>  Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: mappings.length,
//                           itemBuilder: (_, i) {
//                             final entry = mappings.entries.elementAt(i);
//                             return Card(
//                               child: ListTile(
//                                 title: Text("Pose: ${entry.key}"),
//                                 subtitle: Text("Variable: ${entry.value}"),
//                                 trailing: IconButton(
//                                   icon: const Icon(Icons.delete),
//                                   onPressed: () {
//                                     component.removePose(entry.key);
                                    
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => _showAddPoseDialog(context, entity),
//                         child: const Text("Add Pose Trigger"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showAddPoseDialog(BuildContext context, Entity entity) {
//     final component = entity.getComponent<PoseDetectionComponent>()!;
//     const poses = ['waving', 'jumping', 'crouching', 'arms_up', 'standing'];
//     final boolVars = entity.variables.entries
//         .where((e) => e.value is bool)
//         .map((e) => e.key)
//         .toList();

//     String? selectedPose = poses.first;
//     String? selectedVariable = boolVars.isNotEmpty ? boolVars.first : null;

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Add Pose Mapping"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: "Target Pose"),
//               value: selectedPose,
//               items: poses.map((pose) {
//                 return DropdownMenuItem(
//                   value: pose,
//                   child: Text(pose),
//                 );
//               }).toList(),
//               onChanged: (val) => selectedPose = val,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(labelText: "Target Variable"),
//               value: selectedVariable,
//               items: boolVars.map((v) {
//                 return DropdownMenuItem(
//                   value: v,
//                   child: Text(v),
//                 );
//               }).toList(),
//               onChanged: (val) => selectedVariable = val,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (selectedPose != null && selectedVariable != null) {
//                 component.addPose(selectedPose!,selectedVariable!);
//               }
//               Navigator.of(context).pop();
//             },
//             child: const Text("Add"),
//           ),
//         ],
//       ),
//     );
//   }
// }
