import 'package:flutter/material.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';


// ignore: must_be_immutable
class ConditionDraggableBlockWidget extends StatefulWidget {
  ConditionBlock blockModel;
  ConditionDraggableBlockWidget({super.key, required this.blockModel});

  @override
  State<ConditionDraggableBlockWidget> createState() =>
      _ConditionDraggableBlockWidgetState();
}

class _ConditionDraggableBlockWidgetState
    extends State<ConditionDraggableBlockWidget> {
  late TextEditingController _firstValueTextEditingController;
  late TextEditingController _secondValueTextEditingController;

  @override
  void initState() {
    _firstValueTextEditingController = TextEditingController();
    _secondValueTextEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstValueTextEditingController.dispose();
    _secondValueTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> items = const [
      DropdownMenuItem(value: "==", child: Text("==")),
      DropdownMenuItem(value: "!=", child: Text("!=")),
      DropdownMenuItem(value: "<", child: Text("<")),
      DropdownMenuItem(value: ">", child: Text(">")),
      DropdownMenuItem(value: "<=", child: Text("<=")),
      DropdownMenuItem(value: ">=", child: Text(">=")),
    ];

    String selectedOperator = "==";

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), color: Colors.purple),
      width: 100,
      height: 30,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _firstValueTextEditingController,
                decoration: const InputDecoration(hintText: "first value"),
                onChanged: (value) {
                  setState(() {
                    widget.blockModel.firstValue = value;
                  });
                },
              ),
            ),
          ),
          Material(
            child: DropdownButton(
              value: selectedOperator,
              items: items,
              onChanged: (value) {
                setState(() {
                  selectedOperator = value!;
                });
              },
            ),
          ),
          SizedBox(
            width: 30,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _secondValueTextEditingController,
                decoration: const InputDecoration(
                    hintText: "second value",
                    hintStyle: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                onChanged: (value) {
                  setState(() {
                    widget.blockModel.secondValue = value;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}