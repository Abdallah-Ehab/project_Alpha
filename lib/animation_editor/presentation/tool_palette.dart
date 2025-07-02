import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/onin_skin_settings.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ToolPaletteDrawer extends StatelessWidget {
  const ToolPaletteDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final tool = context.watch<ToolSettings>();

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Tool Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Eraser'),
            value: tool.isEraser,
            onChanged: (value) => tool.toggleEraser(),
          ),
          const SizedBox(height: 10),
          Text('Stroke Width: ${tool.strokeWidth.toStringAsFixed(1)}'),
          Slider(
            value: tool.strokeWidth,
            min: 0.5,
            max: 10.0,
            onChanged: tool.setStrokeWidth,
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.color_lens, color: tool.currentColor),
            title: const Text('Pick Color'),
            onTap: () async {
              final selected =
                  await showColorPickerDialog(context, tool.currentColor);
              if (selected != null) {
                tool.setColor(selected);
              }
            },
          ),
          ExpansionTile(
            title: const Text('Onion Skinning'),
            children: [
              SwitchListTile(
                title: const Text('Enable Onion Skinning'),
                value: context.watch<OnionSkinSettings>().enabled,
                onChanged: (_) => context.read<OnionSkinSettings>().toggle(),
              ),
              const Text('Previous Frames'),
              Slider(
                value: context.watch<OnionSkinSettings>().prevFrames.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: '${context.watch<OnionSkinSettings>().prevFrames}',
                onChanged: (val) =>
                    context.read<OnionSkinSettings>().setPrev(val.toInt()),
              ),
              const Text('Next Frames'),
              Slider(
                value: context.watch<OnionSkinSettings>().nextFrames.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: '${context.watch<OnionSkinSettings>().nextFrames}',
                onChanged: (val) =>
                    context.read<OnionSkinSettings>().setNext(val.toInt()),
              ),
            ],
          ),

          
        ],
      ),
    );
  }
}

Future<Color?> showColorPickerDialog(BuildContext context, Color initialColor) {
  Color selectedColor = initialColor;

  return showDialog<Color>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text('Select'),
            onPressed: () => Navigator.of(context).pop(selectedColor),
          ),
        ],
      );
    },
  );
}
