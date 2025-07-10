import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_slider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_text_form_field.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/light_entity.dart';

class EntityPropertiesWidget extends StatefulWidget {
  final Entity entity;

  const EntityPropertiesWidget({super.key, required this.entity});

  @override
  EntityPropertiesWidgetState createState() => EntityPropertiesWidgetState();
}

class EntityPropertiesWidgetState extends State<EntityPropertiesWidget> {
  late TextEditingController nameController;
  late TextEditingController tagController;
  late TextEditingController xController;
  late TextEditingController yController;
  late TextEditingController rotationController;
  late TextEditingController widthController;
  late TextEditingController heightController;
  @override
  void initState() {
    super.initState();
    _initializeControllers();
   
    
  }

  void _initializeControllers() {
    final entity = widget.entity;

    nameController = TextEditingController(text: entity.name);
    tagController = TextEditingController(text: entity.tag);
    xController =
        TextEditingController(text: entity.position.dx.toStringAsFixed(2));
    yController =
        TextEditingController(text: entity.position.dy.toStringAsFixed(2));
    rotationController =
        TextEditingController(text: entity.rotation.toStringAsFixed(2));
    widthController =
        TextEditingController(text: entity.widthScale.toStringAsFixed(2));
    heightController =
        TextEditingController(text: entity.heigthScale.toStringAsFixed(2));
  }

  void _updateControllers() {
    final entity = widget.entity;

    nameController.text = entity.name;
    tagController.text = entity.tag;
    xController.text = entity.position.dx.toStringAsFixed(2);
    yController.text = entity.position.dy.toStringAsFixed(2);
    rotationController.text = entity.rotation.toStringAsFixed(2);
    widthController.text = entity.widthScale.toStringAsFixed(2);
    heightController.text = entity.heigthScale.toStringAsFixed(2);
  }

  @override
  void dispose() {
    nameController.dispose();
    tagController.dispose();
    xController.dispose();
    yController.dispose();
    rotationController.dispose();
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entity = widget.entity;

    return ChangeNotifierProvider.value(
      value: entity,
      child: Consumer<Entity>(
        builder: (context, entity, child) {
          // Update controllers when entity changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateControllers();
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color(0xffE8E8E8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entity: ${entity.name}',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PixelatedTextFormField(
                        label: 'Name',
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        hintText: 'Name',
                        onFieldSubmitted: (value) {
                          entity.setName(value);
                        },
                      ),
                      const SizedBox(height: 10),
                      PixelatedTextFormField(
                        label: 'Tag',
                        controller: tagController,
                        keyboardType: TextInputType.text,
                        hintText: 'Tag',
                        onFieldSubmitted: (value) {
                          entity.tag = value;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: PixelatedTextFormField(
                              label: 'X',
                              controller: xController,
                              hintText: 'Position X',
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (value) {
                                final x = double.tryParse(value);
                                if (x != null) entity.teleport(dx: x);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PixelatedTextFormField(
                              label: 'Y',
                              controller: yController,
                              hintText: 'Position Y',
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (value) {
                                final y = double.tryParse(value);
                                if (y != null) entity.teleport(dy: y);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      PixelatedTextFormField(
                        label: 'R',
                        controller: rotationController,
                        hintText: 'Rotation (degrees)',
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          final rotation = double.tryParse(value);
                          if (rotation != null) entity.rotate(rotation);
                        },
                      ),
                      const SizedBox(height: 10),
                      PixelatedTextFormField(
                        label: 'W',
                        controller: widthController,
                        hintText: 'Width Scale',
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          final width = double.tryParse(value);
                          if (width != null) entity.setWidth(width);
                        },
                      ),
                      const SizedBox(height: 10),
                      PixelatedTextFormField(
                        label: 'H',
                        controller: heightController,
                        hintText: 'Height Scale',
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          final height = double.tryParse(value);
                          if (height != null) entity.setHeight(height);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select Layer',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(10, (index) {
                          final isSelected = index == entity.layerNumber;
                          return GestureDetector(
                            onTap: () {
                              entity.setLayerNumber(index);
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey[700],
                                border: Border.all(color: Colors.white),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      if (entity is LightEntity) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Light Properties',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Color Picker
                        Row(
                          children: [
                            const Text('Color:',
                                style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF333333),
                                      title: const Text('Pick Light Color',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      content: SingleChildScrollView(
                                        child: ColorPicker(
                                          pickerColor: (widget.entity as LightEntity).color,
                                          onColorChanged: (color) {
                                           entity.setSelectedColor(color);
                                          },
                                          enableAlpha: false,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Close',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: (widget.entity as LightEntity).color,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Intensity Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Intensity',
                                style: TextStyle(color: Colors.black)),
                            PixelatedSlider(
                              min: 0,
                              max: 1,
                              divisions: 50,
                              value: (widget.entity as LightEntity).intensity,
                              onChanged: (value) {
                               entity.setLightIntensity(value);
                              },
                              label: 'intensity',
                            ),
                          ],
                        ),

                        // Radius Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Radius',
                                style: TextStyle(color: Colors.black)),
                            PixelatedSlider(
                              label: 'radius',
                              min: 0,
                              max: 200,
                              divisions: 200,
                              value: (widget.entity as LightEntity).radius,
                              onChanged: (value) {
                               entity.setRadius(value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
