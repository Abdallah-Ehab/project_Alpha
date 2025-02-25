import 'package:flutter/material.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';

// ignore: must_be_immutable
class ConditionDraggableBlockWidget extends StatefulWidget {
  ConditionBlock? blockModel;
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

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.greenAccent),
        width: 200,
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              child: TextField(
                controller: _firstValueTextEditingController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "first value"),
                onChanged: (value) {
                  setState(() {
                    if (widget.blockModel != null) {
                      widget.blockModel!.firstValue = value;
                    }
                  });
                },
              ),
            ),
            DropdownButton(
              value: selectedOperator,
              items: items,
              onChanged: (value) {
                setState(() {
                  selectedOperator = value!;
                  if (widget.blockModel != null) {
                    widget.blockModel!.comaparisonOperator = value;
                  }
                });
              },
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _secondValueTextEditingController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "second value",
                    hintStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                onChanged: (value) {
                  setState(() {
                    if (widget.blockModel != null) {
                      widget.blockModel!.secondValue = value;
                    }
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
