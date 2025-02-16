import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Widget> droppedWidgets = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Center(
              child: DragTarget<Widget>(
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        color: Colors.grey,
                        width: 100,
                        height: 100,
                      ),
                      ...droppedWidgets,  // Spread the dropped widgets into the stack
                    ],
                  );
                },
                onAcceptWithDetails: (details) {
                  setState(() {
                    droppedWidgets.add(details.data);
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.red,
            child: Center(
              child: Draggable<Widget>(
                data: Container(  // This widget will be added to droppedWidgets
                  color: Colors.blueAccent,
                  width: 100,
                  height: 100,
                ),
                feedback: Container(
                  color: Colors.deepPurple,
                  width: 100,
                  height: 100,
                ),
                childWhenDragging: Container(
                  color: Colors.blueAccent,
                  width: 100,
                  height: 100,
                ),
                child: Container(
                  color: Colors.blueAccent,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}