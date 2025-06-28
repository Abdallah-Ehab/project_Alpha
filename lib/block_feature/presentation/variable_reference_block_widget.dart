// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:scratch_clone/block_feature/data/block_model.dart';
// import 'package:scratch_clone/block_feature/presentation/condition_block_widget.dart';
// import 'package:scratch_clone/entity/data/entity.dart';

// class VariableReferenceBlockWidget extends StatefulWidget {
//   final VariableReferenceBlock blockModel;
//   const VariableReferenceBlockWidget({super.key, required this.blockModel});

//   @override
//   State<VariableReferenceBlockWidget> createState() => _VariableReferenceBlockWidgetState();
// }

// class _VariableReferenceBlockWidgetState extends State<VariableReferenceBlockWidget> {
//   late TextEditingController variableNameController;
  
//   @override
//   void initState() {
//     super.initState();
//     variableNameController = TextEditingController(text: widget.blockModel.variableName);
//   }
  
//   @override
//   void dispose() {
//     variableNameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Entity>(
//       builder: (context, entity, child) {
//         // Get list of available variables
//         final availableVariables = entity.variables.keys.toList();
        
//         return CustomPaint(
//           painter: HexagonalBlockPainter(color: widget.blockModel.color),
//           child: Container(
//             width: widget.blockModel.width,
//             height: widget.blockModel.height,
//             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Label for the block
//                 const Material(
//                   color:Colors.transparent,
//                   child: Text(
//                     "Get var:",
//                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
                
//                 // Variable name field with dropdown
//                 Expanded(
//                   child: _buildVariableSelector(availableVariables, entity),
//                 ),
                
//                 // Preview of variable value
//                 if (widget.blockModel.variableName.isNotEmpty && 
//                     entity.variables.containsKey(widget.blockModel.variableName))
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white10,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: Text(
//                         "= ${_formatValue(entity.variables[widget.blockModel.variableName])}",
//                         style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       }
//     );
//   }
  
//   Widget _buildVariableSelector(List<String> availableVariables, Entity entity) {
//     // If no variables exist yet, show text field only
//     if (availableVariables.isEmpty) {
//       return Material(
//         color: Colors.white24,
//         borderRadius: BorderRadius.circular(4),
//         child: TextField(
//           controller: variableNameController,
//           style: const TextStyle(color: Colors.white),
//           decoration: const InputDecoration(
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//             border: InputBorder.none,
//             hintText: "variable name",
//             hintStyle: TextStyle(color: Colors.white70),
//             suffixIcon: Icon(Icons.warning, color: Colors.amber, size: 16),
//             suffixIconConstraints: BoxConstraints(minWidth: 16, minHeight: 16),
//           ),
//           onChanged: (value) {
//             widget.blockModel.setVariableName(value);
//           },
//         ),
//       );
//     }
    
//     // Otherwise, use a combo of text field and dropdown
//     return Stack(
//       alignment: Alignment.centerRight,
//       children: [
//         // Text field
//         Material(
//           color: Colors.white24,
//           borderRadius: BorderRadius.circular(4),
//           child: TextField(
//             controller: variableNameController,
//             style: const TextStyle(color: Colors.white),
//             decoration: const InputDecoration(
//               contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//               border: InputBorder.none,
//               hintText: "variable name",
//               hintStyle: TextStyle(color: Colors.white70),
//             ),
//             onChanged: (value) {
//               widget.blockModel.setVariableName(value);
//             },
//           ),
//         ),
        
//         // Dropdown button
//         Material(
//           color: Colors.transparent,
//           child: PopupMenuButton<String>(
//             icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
//             onSelected: (String value) {
//               variableNameController.text = value;
//               widget.blockModel.setVariableName(value);
//             },
//             itemBuilder: (BuildContext context) {
//               return availableVariables.map((String value) {
//                 final dynamic varValue = entity.variables[value];
//                 return PopupMenuItem<String>(
//                   value: value,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(value),
//                       const SizedBox(width: 8),
//                       Text(
//                         _formatValue(varValue),
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 12,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList();
//             },
//           ),
//         ),
//       ],
//     );
//   }
  
//   String _formatValue(dynamic value) {
//     if (value == null) {
//       return "null";
//     }
//     // For other types, just use toString() but limit length
//     final stringValue = value.toString();
//     if (stringValue.length > 15) {
//       return "${stringValue.substring(0, 12)}...";
//     }
    
//     return stringValue;
//   }
// }