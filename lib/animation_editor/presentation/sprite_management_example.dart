// Solution 1: Save Custom Paint to Image
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



// class DrawingFrame {
//   List<Offset> points;
//   Paint paintSettings;

//   DrawingFrame({required this.points, required this.paintSettings});
// }

// class AnimationFramePainter extends CustomPainter {
//   final List<DrawingFrame> frames;
//   final ui.Image? backgroundImage;

//   AnimationFramePainter({required this.frames, this.backgroundImage});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw background image if exists
//     if (backgroundImage != null) {
//       canvas.drawImage(backgroundImage!, Offset.zero, Paint());
//     }

//     // Draw all frames
//     for (var frame in frames) {
//       if (frame.points.isNotEmpty) {
//         for (int i = 0; i < frame.points.length - 1; i++) {
//           if (frame.points[i] != Offset.zero && frame.points[i + 1] != Offset.zero) {
//             canvas.drawLine(frame.points[i], frame.points[i + 1], frame.paintSettings);
//           }
//         }
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // Widget for drawing with save capability
// class DrawingCanvas extends StatefulWidget {
//   final Function(Uint8List) onFrameSaved;

//   const DrawingCanvas({Key? key, required this.onFrameSaved}) : super(key: key);

//   @override
//   _DrawingCanvasState createState() => _DrawingCanvasState();
// }

// class _DrawingCanvasState extends State<DrawingCanvas> {
//   final GlobalKey _canvasKey = GlobalKey();
//   List<DrawingFrame> frames = [];
//   List<Offset> currentPoints = [];

//   Paint get currentPaint => Paint()
//     ..color = Colors.black
//     ..strokeCap = StrokeCap.round
//     ..strokeWidth = 3.0;

//   // Method to save canvas as image
//   Future<void> saveCanvasAsImage() async {
//     try {
//       RenderRepaintBoundary boundary =
//           _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData != null) {
//         Uint8List pngBytes = byteData.buffer.asUint8List();
//         widget.onFrameSaved(pngBytes);

//         // Optional: Save to device storage
//         await _saveToFile(pngBytes);
//       }
//     } catch (e) {
//       print('Error saving canvas: $e');
//     }
//   }

//   Future<void> _saveToFile(Uint8List bytes) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/frame_${DateTime.now().millisecondsSinceEpoch}.png');
//       await file.writeAsBytes(bytes);
//       print('Frame saved to: ${file.path}');
//     } catch (e) {
//       print('Error saving file: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: RepaintBoundary(
//             key: _canvasKey,
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               color: Colors.white,
//               child: GestureDetector(
//                 onPanUpdate: (details) {
//                   setState(() {
//                     currentPoints.add(details.localPosition);
//                   });
//                 },
//                 onPanEnd: (details) {
//                   frames.add(DrawingFrame(
//                     points: List.from(currentPoints),
//                     paintSettings: Paint()
//                       ..color = currentPaint.color
//                       ..strokeWidth = currentPaint.strokeWidth
//                       ..strokeCap = currentPaint.strokeCap,
//                   ));
//                   currentPoints.clear();
//                 },
//                 child: CustomPaint(
//                   painter: AnimationFramePainter(frames: frames),
//                   size: Size.infinite,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: saveCanvasAsImage,
//                 child: Text('Save Frame'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     frames.clear();
//                     currentPoints.clear();
//                   });
//                 },
//                 child: Text('Clear'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// Solution 2: Sprite Sheet Slicer
class SpriteSheetSlicer extends StatefulWidget {
  final ui.Image spriteSheet;
  final void Function(List<ui.Image>) onSpritesExtracted;

  const SpriteSheetSlicer({
    super.key,
    required this.spriteSheet,
    required this.onSpritesExtracted,
  });

  @override
  SpriteSheetSlicerState createState() => SpriteSheetSlicerState();
}

class SpriteSheetSlicerState extends State<SpriteSheetSlicer> {
  int rows = 1;
  int columns = 1;
  double offsetX = 0;
  double offsetY = 0;
  double spacing = 0;
  int startSprite = 1;
  int endSprite = 1;

  // Color keying properties
  Color keyColor = Colors.pink;
  bool enableColorKeying = false;
  double colorTolerance = 0.1; // 0.0 to 1.0

  final TextEditingController _startSpriteController = TextEditingController();
  final TextEditingController _endSpriteController = TextEditingController();
  final TextEditingController _colorTextController = TextEditingController();
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _startSpriteController.text = startSprite.toString();
    _endSpriteController.text = endSprite.toString();
    _colorTextController.text = Colors.pink.toHexString();
    super.initState();
  }

  @override
  void dispose() {
    _startSpriteController.dispose();
    _endSpriteController.dispose();
    _colorTextController.dispose();
    super.dispose();
  }

  int get totalSprites => rows * columns;
  int get spriteCount => (endSprite - startSprite + 1).clamp(0, totalSprites);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Controls
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Grid controls
                    Row(
                      children: [
                        Expanded(
                          child: Text('Columns: $columns'),
                        ),
                        Expanded(
                          child: Slider(
                            value: columns.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                columns = value.round();
                                _updateSpriteRange();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Rows: $rows'),
                        ),
                        Expanded(
                          child: Slider(
                            value: rows.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                rows = value.round();
                                _updateSpriteRange();
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Sprite range controls
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Sprite:'),
                              TextField(
                                controller: _startSpriteController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '1',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                onChanged: (value) {
                                  int? newStart = int.tryParse(value);
                                  if (newStart != null &&
                                      newStart > 0 &&
                                      newStart <= totalSprites) {
                                    setState(() {
                                      startSprite = newStart;
                                      if (endSprite < startSprite) {
                                        endSprite = startSprite;
                                        _endSpriteController.text =
                                            endSprite.toString();
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Sprite:'),
                              TextField(
                                controller: _endSpriteController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '1',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                onChanged: (value) {
                                  int? newEnd = int.tryParse(value);
                                  if (newEnd != null &&
                                      newEnd >= startSprite &&
                                      newEnd <= totalSprites) {
                                    setState(() {
                                      endSprite = newEnd;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    Text(
                        'Will extract $spriteCount sprites ($startSprite to $endSprite)'),
                    Text('number of sprite is $totalSprites'),
                    // Offset and spacing controls
                    Row(
                      children: [
                        Expanded(
                          child: Text('Offset X: ${offsetX.round()}'),
                        ),
                        Expanded(
                          child: Slider(
                            value: offsetX,
                            min: 0,
                            max: 100,
                            onChanged: (value) {
                              setState(() {
                                offsetX = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Offset Y: ${offsetY.round()}'),
                        ),
                        Expanded(
                          child: Slider(
                            value: offsetY,
                            min: 0,
                            max: 100,
                            onChanged: (value) {
                              setState(() {
                                offsetY = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Spacing: ${spacing.round()}'),
                        ),
                        Expanded(
                          child: Slider(
                            value: spacing,
                            min: 0,
                            max: 20,
                            onChanged: (value) {
                              setState(() {
                                spacing = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Color keying controls
                    Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: enableColorKeying,
                          onChanged: (value) {
                            setState(() {
                              enableColorKeying = value ?? false;
                            });
                          },
                        ),
                        Text('Enable Color Keying'),
                      ],
                    ),

                    if (enableColorKeying) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text('Key Color:'),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showColorPicker(),
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: keyColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    'Tap to change',
                                    style: TextStyle(
                                      color: keyColor.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                                'Tolerance: ${(colorTolerance * 100).round()}%'),
                          ),
                          Expanded(
                            child: Slider(
                              value: colorTolerance,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (value) {
                                setState(() {
                                  colorTolerance = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Preview
          Expanded(
            flex: 8,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: CustomPaint(
                painter: SpriteSheetPreviewPainter(
                  image: widget.spriteSheet,
                  rows: rows,
                  columns: columns,
                  offsetX: offsetX,
                  offsetY: offsetY,
                  spacing: spacing,
                  startSprite: startSprite,
                  endSprite: endSprite,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // Extract button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: spriteCount > 0 ? () => _extractSprites() : null,
              child: Text('Extract $spriteCount Sprites'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateSpriteRange() {
    int maxSprites = totalSprites;
    if (startSprite > maxSprites) {
      startSprite = maxSprites;
      _startSpriteController.text = startSprite.toString();
    }
    if (endSprite > maxSprites) {
      endSprite = maxSprites;
      _endSpriteController.text = endSprite.toString();
    }
  }

  Future<Color?> showColorPickerDialog(
      BuildContext context, Color initialColor) {
    Color selectedColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              
              hexInputBar: true,
              hexInputController: _colorTextController,
              onColorChanged: (color) {
                selectedColor = color;
              },
              pickerColor: selectedColor,
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

  void _showColorPicker() async {
    Color? newColor = await showColorPickerDialog(context, keyColor);
    if (newColor != null) {
      setState(() {
        keyColor = newColor;
      });
    }
  }

  Future<void> _extractSprites() async {
  List<ui.Image> sprites = [];
  
  double spriteWidth = (widget.spriteSheet.width - offsetX * 2 - spacing * (columns - 1)) / columns;
  double spriteHeight = (widget.spriteSheet.height - offsetY * 2 - spacing * (rows - 1)) / rows;
  
  int currentSpriteIndex = 1;
  
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < columns; col++) {
      if (currentSpriteIndex >= startSprite && currentSpriteIndex <= endSprite) {
        double x = offsetX + col * (spriteWidth + spacing);
        double y = offsetY + row * (spriteHeight + spacing);
        
        ui.Image sprite = await _cropImage(
          widget.spriteSheet,
          x.round(),
          y.round(),
          spriteWidth.round(),
          spriteHeight.round(),
        );
        
        // Apply color keying if enabled - to the CROPPED sprite, not the original image
        if (enableColorKeying) {
          sprite = await _applyColorKeying(sprite);
        }
        
        sprites.add(sprite);
      }
      currentSpriteIndex++;
    }
  }
  
  widget.onSpritesExtracted(sprites);
}

  Future<ui.Image> _cropImage(
      ui.Image image, int x, int y, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final srcRect = Rect.fromLTWH(
        x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }

 Future<ui.Image> _applyColorKeying(ui.Image image) async {
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return image;
  
  Uint8List originalPixels = byteData.buffer.asUint8List();
  Uint8List modifiedPixels = Uint8List.fromList(originalPixels); // Create a copy
  
  // Extract key color components (convert to 0-255 range)
  int keyR = (keyColor.r * 255).round();
  int keyG = (keyColor.g * 255).round();
  int keyB = (keyColor.b * 255).round();
  
  // Calculate tolerance threshold
  double threshold = colorTolerance * 255;
  
  // Process each pixel
  for (int i = 0; i < modifiedPixels.length; i += 4) {
    int r = modifiedPixels[i];
    int g = modifiedPixels[i + 1];
    int b = modifiedPixels[i + 2];
    
    // Calculate color distance
    double distance = _colorDistance(r, g, b, keyR, keyG, keyB);
    
    // If pixel is within tolerance of key color, make it completely transparent
    if (distance <= threshold) {
      modifiedPixels[i] = 0;     
      modifiedPixels[i + 1] = 0; 
      modifiedPixels[i + 2] = 0; 
      modifiedPixels[i + 3] = 0;
    }
  }
  
  // Create new image with modified pixels
  final Completer<ui.Image> completer = Completer<ui.Image>();
  
  ui.decodeImageFromPixels(
    modifiedPixels,
    image.width,
    image.height,
    ui.PixelFormat.rgba8888,
    (ui.Image result) {
      completer.complete(result);
    },
  );
  
  return completer.future;
}

double _colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
  // Calculate Euclidean distance in RGB space
  double dr = (r1 - r2).toDouble();
  double dg = (g1 - g2).toDouble();
  double db = (b1 - b2).toDouble();
  return sqrt(dr * dr + dg * dg + db * db);
}
}

class SpriteSheetPreviewPainter extends CustomPainter {
  final ui.Image image;
  final int rows;
  final int columns;
  final double offsetX;
  final double offsetY;
  final double spacing;
  final int startSprite;
  final int endSprite;

  SpriteSheetPreviewPainter({
    required this.image,
    required this.rows,
    required this.columns,
    required this.offsetX,
    required this.offsetY,
    required this.spacing,
    required this.startSprite,
    required this.endSprite,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale to fit image in widget
    double scaleX = size.width / image.width;
    double scaleY = size.height / image.height;
    double scale = scaleX < scaleY ? scaleX : scaleY;

    // Draw the sprite sheet
    canvas.save();
    canvas.scale(scale);
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw grid lines
    Paint gridPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0 / scale
      ..style = PaintingStyle.stroke;

    // Draw highlighted sprites that will be extracted
    Paint highlightPaint = Paint()
      ..color = Colors.green.withAlpha(100)
      ..style = PaintingStyle.fill;

    // Draw border for sprites that will be extracted
    Paint borderPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0 / scale
      ..style = PaintingStyle.stroke;

    double spriteWidth =
        (image.width - offsetX * 2 - spacing * (columns - 1)) / columns;
    double spriteHeight =
        (image.height - offsetY * 2 - spacing * (rows - 1)) / rows;

    // Highlight sprites that will be extracted
    int currentSpriteIndex = 1;
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        double x = offsetX + col * (spriteWidth + spacing);
        double y = offsetY + row * (spriteHeight + spacing);

        Rect spriteRect = Rect.fromLTWH(x, y, spriteWidth, spriteHeight);

        if (currentSpriteIndex >= startSprite &&
            currentSpriteIndex <= endSprite) {
          // Highlight and border for selected sprites
          canvas.drawRect(spriteRect, highlightPaint);
          canvas.drawRect(spriteRect, borderPaint);
        }

        currentSpriteIndex++;
      }
    }

    // Draw grid lines for rows
    for (int row = 0; row <= rows; row++) {
      double y =
          offsetY + row * (spriteHeight + spacing) - (row > 0 ? spacing : 0);
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(image.width - offsetX, y),
        gridPaint,
      );
    }

    // Draw grid lines for columns
    for (int col = 0; col <= columns; col++) {
      double x =
          offsetX + col * (spriteWidth + spacing) - (col > 0 ? spacing : 0);
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, image.height - offsetY),
        gridPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
