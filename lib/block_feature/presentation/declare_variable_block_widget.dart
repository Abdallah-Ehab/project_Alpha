// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:scratch_clone/block_feature/data/block_model.dart';
// import 'package:scratch_clone/block_feature/presentation/condition_block_widget.dart';
// import 'package:scratch_clone/entity/data/entity.dart';

// class DeclareVariableBlockWidget extends StatefulWidget {
//   final DeclareVarableBlock blockModel;
//   const DeclareVariableBlockWidget({super.key, required this.blockModel});

//   @override
//   State<DeclareVariableBlockWidget> createState() => _DeclareVariableBlockWidgetState();
// }

// class _DeclareVariableBlockWidgetState extends State<DeclareVariableBlockWidget> {
//   late TextEditingController nameController;
//   late TextEditingController valueController;
  
//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.blockModel.variableName);
//     valueController = TextEditingController(text: widget.blockModel.value?.toString() ?? "");
//   }
  
//   @override
//   void dispose() {
//     nameController.dispose();
//     valueController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: HexagonalBlockPainter(color: widget.blockModel.color),
//       child: Container(
//         width: widget.blockModel.width,
//         height: widget.blockModel.height,
//         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Label for the block
//             const Material(
//               color: Colors.transparent,
//               child: Text(
//                 "Declare:",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(width: 8),
            
//             // Variable name field
//             SizedBox(
//               width: 30,
//               child: Material(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(4),
//                 child: TextField(
//                   controller: nameController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//                     border: InputBorder.none,
//                     hintText: "variable name",
//                     hintStyle: TextStyle(color: Colors.white70),
//                   ),
//                   onChanged: (value) {
//                     // Only update if not empty
//                     if (value.isNotEmpty) {
//                       widget.blockModel.setVariableName(value);
//                     }
//                   },
//                 ),
//               ),
//             ),
            
//             const SizedBox(width: 8),
            
//             // Assignment operator
//             const Material(
//               color: Colors.transparent,
//               child: Text(
//                 "=",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ),
            
//             const SizedBox(width: 8),
            
//             // Value field
//             SizedBox(
//               width: 30,
//               child: Material(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(4),
//                 child: TextField(
//                   controller: valueController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: const InputDecoration(
//                     contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//                     border: InputBorder.none,
//                     hintText: "value",
//                     hintStyle: TextStyle(color: Colors.white70),
//                   ),
//                   onChanged: (value) {
//                     // Try to parse as number first
//                     final numValue = double.tryParse(value);
//                     if (numValue != null) {
//                       widget.blockModel.setVariableValue(numValue);
//                     } else {
//                       // Treat as string if not a number
//                       widget.blockModel.setVariableValue(value);
//                     }
//                   },
//                 ),
//               ),
//             ),
            
//             const SizedBox(width: 8),
            
//             // Confirm button
//             Consumer<Entity>(
//               builder: (context, entity, child) {
//                 return IconButton(
//                   icon: const Icon(Icons.check_circle, color: Colors.white),
//                   tooltip: "Confirm variable declaration",
//                   onPressed: () {
//                     _confirmVariableDeclaration(context, entity);
//                   },
//                 );
//               }
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   void _confirmVariableDeclaration(BuildContext context, Entity entity) {
//     final String name = nameController.text.trim();
//     final String value = valueController.text.trim();
    
//     // Basic validation
//     if (name.isEmpty) {
//       _showErrorDialog(context, "Variable name cannot be empty");
//       return;
//     }
    
//     if (value.isEmpty) {
//       _showErrorDialog(context, "Variable value cannot be empty");
//       return;
//     }
    
//     // Check if variable already exists
//     if (entity.variables.containsKey(name)) {
//       _showErrorDialog(
//         context, 
//         "Variable '$name' already exists. Use a different name.",
//         showOverwriteOption: true,
//         onOverwrite: () {
//           // Parse the value
//           final dynamic parsedValue = _parseValue(value);
//           // Update the variable
//           entity.addVariable(name: name, value: parsedValue);
//           Navigator.of(context).pop(); // Close dialog
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Variable '$name' updated successfully"))
//           );
//         }
//       );
//       return;
//     }
    
//     // Parse the value
//     final dynamic parsedValue = _parseValue(value);
    
//     // Add the variable to the entity
//     entity.addVariable(name: name, value: parsedValue);
    
//     // Show confirmation
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Variable '$name' declared successfully"))
//     );
//   }
  
//   dynamic _parseValue(String value) {
//     // Try parsing as number
//     final double? numValue = double.tryParse(value);
//     if (numValue != null) {
//       return numValue;
//     }
    
//     // Check for boolean
//     if (value.toLowerCase() == 'true') {
//       return true;
//     }
//     if (value.toLowerCase() == 'false') {
//       return false;
//     }
    
//     return value;
//   }
  
//   void _showErrorDialog(BuildContext context, String message, {
//     bool showOverwriteOption = false,
//     VoidCallback? onOverwrite,
//   }) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Variable Declaration Error"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("OK"),
//           ),
//           if (showOverwriteOption && onOverwrite != null)
//             TextButton(
//               onPressed: onOverwrite,
//               child: const Text("Overwrite"),
//             ),
//         ],
//       ),
//     );
//   }
// }