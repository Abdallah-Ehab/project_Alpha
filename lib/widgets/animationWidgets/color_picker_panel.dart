import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/constants/colors/colors.dart'; // Assuming theme colors are defined here
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Color",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Display Color Rows with Themed Look
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: MyColors.deepBlue, // Themed background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var row in colorRows)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map(
                        (color) => GestureDetector(
                          onTap: () {
                            sketchProvider.currentColor = color;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(6),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: sketchProvider.currentColor == color
                                    ? MyColors.pastelPeach
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                if (sketchProvider.currentColor == color)
                                  BoxShadow(
                                    color: MyColors.pastelPeach.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 3,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),

              // Color Picker Button (Bubbly Style)
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Color tempColor = sketchProvider.currentColor;
                      return AlertDialog(
                        backgroundColor: MyColors.deepBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Pick a Color",
                          style: TextStyle(color: Colors.white),
                        ),
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
                            child: Text("Cancel", style: TextStyle(color: MyColors.pastelPeach)),
                          ),
                          TextButton(
                            onPressed: () {
                              sketchProvider.currentColor = tempColor;
                              Navigator.of(context).pop();
                            },
                            child: Text("Select", style: TextStyle(color: MyColors.babyBlue)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.deepBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child:  Text("Pick Custom Color",style: TextStyle(color: MyColors.pastelPeach),),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
