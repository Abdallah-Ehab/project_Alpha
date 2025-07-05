// Solution 1: Save Custom Paint to Image
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_feature/data/animation_controller_component.dart';
import 'dart:io';

import 'package:scratch_clone/entity/data/entity_manager.dart';

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
  int spriteCount = 1;
  
  final TextEditingController _spriteCountController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _spriteCountController.text = spriteCount.toString();
    super.initState();
  }
  
  @override
  void dispose() {
    _spriteCountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Controls
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Sprites to Extract:'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _spriteCountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter number',
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onChanged: (value) {
                              int? newCount = int.tryParse(value);
                              if (newCount != null && newCount > 0) {
                                setState(() {
                                  spriteCount = newCount;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
                  spriteCount: spriteCount,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          
          // Extract button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _extractSprites(),
              child: Text('Extract $spriteCount Sprites'),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _extractSprites() async {
    List<ui.Image> sprites = [];
    
    double spriteWidth = (widget.spriteSheet.width - offsetX * 2 - spacing * (columns - 1)) / columns;
    double spriteHeight = (widget.spriteSheet.height - offsetY * 2 - spacing * (rows - 1)) / rows;
    
    int extractedCount = 0;
    
    for (int row = 0; row < rows && extractedCount < spriteCount; row++) {
      for (int col = 0; col < columns && extractedCount < spriteCount; col++) {
        double x = offsetX + col * (spriteWidth + spacing);
        double y = offsetY + row * (spriteHeight + spacing);
        
        ui.Image sprite = await _cropImage(
          widget.spriteSheet,
          x.round(),
          y.round(),
          spriteWidth.round(),
          spriteHeight.round(),
        );
        
        sprites.add(sprite);
        extractedCount++;
      }
    }
    
    widget.onSpritesExtracted(sprites);
  }
  
  Future<ui.Image> _cropImage(ui.Image image, int x, int y, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final srcRect = Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
    
    final picture = recorder.endRecording();
    return await picture.toImage(width, height);
  }
}

class SpriteSheetPreviewPainter extends CustomPainter {
  final ui.Image image;
  final int rows;
  final int columns;
  final double offsetX;
  final double offsetY;
  final double spacing;
  final int spriteCount;
  
  SpriteSheetPreviewPainter({
    required this.image,
    required this.rows,
    required this.columns,
    required this.offsetX,
    required this.offsetY,
    required this.spacing,
    required this.spriteCount,
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
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    double spriteWidth = (image.width - offsetX * 2 - spacing * (columns - 1)) / columns;
    double spriteHeight = (image.height - offsetY * 2 - spacing * (rows - 1)) / rows;
    
    // Highlight sprites that will be extracted
    int highlightedCount = 0;
    for (int row = 0; row < rows && highlightedCount < spriteCount; row++) {
      for (int col = 0; col < columns && highlightedCount < spriteCount; col++) {
        double x = offsetX + col * (spriteWidth + spacing);
        double y = offsetY + row * (spriteHeight + spacing);
        
        canvas.drawRect(
          Rect.fromLTWH(x, y, spriteWidth, spriteHeight),
          highlightPaint,
        );
        highlightedCount++;
      }
    }
    
    // Draw grid lines for rows
    for (int row = 0; row <= rows; row++) {
      double y = offsetY + row * (spriteHeight + spacing) - (row > 0 ? spacing : 0);
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(image.width - offsetX, y),
        gridPaint,
      );
    }
    
    // Draw grid lines for columns
    for (int col = 0; col <= columns; col++) {
      double x = offsetX + col * (spriteWidth + spacing) - (col > 0 ? spacing : 0);
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