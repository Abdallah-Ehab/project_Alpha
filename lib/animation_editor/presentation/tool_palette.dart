import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/onin_skin_settings.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_track_control_panel.dart';
import 'package:scratch_clone/animation_editor/presentation/upload_image_button.dart';
import 'package:scratch_clone/animation_editor/presentation/upload_sprite_button.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';

class ToolPaletteDrawer extends StatelessWidget {
  const ToolPaletteDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final tool = context.watch<ToolSettings>();

    return Drawer(
      backgroundColor: Color(0xff222222),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
  color: const Color(0xff888888),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Tool Settings',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "PressStart2P",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Eraser toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Eraser',
              style: TextStyle(
                color: Colors.white,
                fontFamily: "PressStart2P",
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: tool.isEraser,
              onChanged: (value) => tool.toggleEraser(),
              activeColor: const Color(0xff555555),
              activeTrackColor: const Color(0xff222222),
              inactiveThumbColor: const Color(0xff222222),
              inactiveTrackColor: const Color(0xff555555),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stroke width label and slider
        Text(
          'Stroke Width: ${tool.strokeWidth.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "PressStart2P",
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        PixelatedSlider(
          label: "",
          value: tool.strokeWidth,
          min: 0.5,
          max: 10.0,
          onChanged: tool.setStrokeWidth,
        ),
        const SizedBox(height: 20),

        // Color picker
        GestureDetector(
          onTap: () async {
            final selected = await showColorPickerDialog(
              context,
              tool.currentColor,
            );
            if (selected != null) {
              tool.setColor(selected);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xff666666),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.color_lens, color: tool.currentColor),
                const SizedBox(width: 12),
                const Text(
                  'Pick Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "PressStart2P",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),SizedBox(height: 16,),
          Card(
            color: Color(0xff888888) ,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: const Text('Onion Skinning',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "PressStart2P",
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                children: [
                  SwitchListTile(
                    title: const Text('Enable Onion Skinning',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "PressStart2P",
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    value: context.watch<OnionSkinSettings>().enabled,
                    onChanged: (_) => context.read<OnionSkinSettings>().toggle(),
                  ),
                  const Text('Previous Frames'),
                  PixelatedSlider(
                    value: context.watch<OnionSkinSettings>().prevFrames.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: '${context.watch<OnionSkinSettings>().prevFrames}',
                    onChanged: (val) =>
                        context.read<OnionSkinSettings>().setPrev(val.toInt()),
                  ),
                  const Text('Next Frames'),
                  PixelatedSlider(
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
            ),
          ),
          AnimationTrackControlPanel(),
          const SizedBox(height: 20),
          UploadFramesButton(),
          const SizedBox(height: 10),
          UploadSpriteButton()
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
