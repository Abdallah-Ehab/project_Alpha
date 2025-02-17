import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';

class ColorPickerPanel extends StatefulWidget {
  const ColorPickerPanel({super.key});

  @override
  _ColorPickerPanelState createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends State<ColorPickerPanel> {
  final List<List<Color>> colorRows = [
    [Colors.red, Colors.green, Colors.blue],
    [Colors.orange, Colors.purple, Colors.teal],
    [Colors.yellow, Colors.brown, Colors.pink]
  ];

  @override
  Widget build(BuildContext context) {
    var sketchProvider = Provider.of<SketchProvider>(context);

    return Column(
      children: [
        // Display Color Rows
        for (var row in colorRows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row
                .map((color) => GestureDetector(
                      onTap: () {
                        sketchProvider.currentColor = color;
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: sketchProvider.currentColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

        // Color Picker Button
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                Color tempColor = sketchProvider.currentColor;
                return AlertDialog(
                  title: const Text("Pick a Color"),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (color) {
                       
                       
                          
                        tempColor = color;
                      
                      },
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        sketchProvider.currentColor = tempColor;
                        Navigator.of(context).pop();
                      },
                      child: const Text("Select"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text("Pick Custom Color"),
        ),
      ],
    );
  }
}