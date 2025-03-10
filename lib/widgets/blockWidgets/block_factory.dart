import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/models/blockModels/block_model.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/widgets/blockWidgets/condition_block_target_widget.dart';


class BlockFactory extends StatelessWidget {
  BlockModel blockModel;
  BlockFactory({super.key, required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return blockModel.constructBlock();
  }
}

class GenericBlockWidget extends StatelessWidget {
  BlockModel blockModel;
  GenericBlockWidget({super.key,required this.blockModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size:  Size(blockModel.width, blockModel.height),
            painter: BlockPainter(color: blockModel.color, widthFactor:1.0,heightFactor: 1.0),
          ),
          const Material(
              color: Colors.transparent, child: Text("start block")
              ),
        ],
      );
  }
}

class IfBlockWidget extends StatefulWidget {
  final IfStatementBlock blockModel;
  const IfBlockWidget(
      {super.key, required this.blockModel});

  @override
  State<IfBlockWidget> createState() => _IfBlockWidgetState();
}

class _IfBlockWidgetState extends State<IfBlockWidget> {
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size:  Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
              color: widget.blockModel.color, widthFactor: 1.0, heightFactor: 1.0),
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Material(
              color: Colors.transparent,
              child: Text(
                "if",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
            ConditionBlockTargetWidget(blockModel: widget.blockModel)
          ],
        )
      ],
    );
  }
}

class PlayAnimationBlockWidget extends StatefulWidget {
  final PlayAnimationBlock blockModel;
  const PlayAnimationBlockWidget({
    super.key,
    required this.blockModel,
  });

  @override
  State<PlayAnimationBlockWidget> createState() =>
      _PlayAnimationBlockWidgetState();
}

class _PlayAnimationBlockWidgetState extends State<PlayAnimationBlockWidget> {
  String? selectedTrack;
  @override
  Widget build(BuildContext context) {
    var gameObjectManagerProvider =
        Provider.of<GameObjectManagerProvider>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size:  Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
              color: widget.blockModel.color,
              widthFactor: 1,
              heightFactor: 1.5),
        ),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: Text(
                widget.blockModel.code,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 50),
            Material(
              child: SizedBox(
                height: 30,
                child: DropdownButton(
                    value: "idle",
                    focusColor: widget.blockModel.color,
                    items: gameObjectManagerProvider
                        .currentGameObject.animationTracks.keys
                        .map((track) =>
                            DropdownMenuItem(value: track, child: Text(track)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        log(value);
                      }
                      setState(() {
                        selectedTrack = value;
                        widget.blockModel.trackName = value;
                      });
                    }),
              ),
            )
          ],
        )
      ],
    );
  }
}

class ChangePositionBlockWidget extends StatefulWidget {
  final ChangePositionBlock blockModel;

  const ChangePositionBlockWidget({super.key, required this.blockModel});

  @override
  State<ChangePositionBlockWidget> createState() => _ChangePositionBlockWidgetState();
}

class _ChangePositionBlockWidgetState extends State<ChangePositionBlockWidget> {
  final TextEditingController _dxController = TextEditingController();
  final TextEditingController _dyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dxController.text = widget.blockModel.dx?.toString() ?? "";
    _dyController.text = widget.blockModel.dy?.toString() ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size:  Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
            color: widget.blockModel.color,
            widthFactor: 1.0,
            heightFactor: 1.0,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Material(
              color: Colors.transparent,
              child: Text(
                "Change Position",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _dxController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "X",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        
                        widget.blockModel.dx = double.tryParse(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 30,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _dyController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "Y",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        widget.blockModel.dy = double.tryParse(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _dxController.dispose();
    _dyController.dispose();
    super.dispose();
  }
}


class ChangeRotationBlockWidget extends StatefulWidget {
  final ChangeRotationBlock blockModel;

  const ChangeRotationBlockWidget({super.key, required this.blockModel});

  @override
  State<ChangeRotationBlockWidget> createState() => _ChangeRotationBlockWidget();
}

class _ChangeRotationBlockWidget extends State<ChangeRotationBlockWidget> {
  final TextEditingController _rotationTextController = TextEditingController();
 

  @override
  void initState() {
    super.initState();
    _rotationTextController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size:  Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
            color: widget.blockModel.color,
            widthFactor: 1.0,
            heightFactor: 1.0,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Material(
              color: Colors.transparent,
              child: Text(
                "Change rotation",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _rotationTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "angle",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        widget.blockModel.angle = double.tryParse(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
               
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _rotationTextController.dispose();
    super.dispose();
  }
}

class ChangeScaleBlockWidget extends StatefulWidget {
  final ChangeScaleBlock blockModel;

  const ChangeScaleBlockWidget({super.key, required this.blockModel});

  @override
  State<ChangeScaleBlockWidget> createState() => _ChangeScaleBlockWidget();
}

class _ChangeScaleBlockWidget extends State<ChangeScaleBlockWidget> {
  final TextEditingController _scaleTextController = TextEditingController();
 

  @override
  void initState() {
    super.initState();
    _scaleTextController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size:  Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
            color: widget.blockModel.color,
            widthFactor: 1.0,
            heightFactor: 1.0,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Material(
              color: Colors.transparent,
              child: Text(
                "Change scale",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: _scaleTextController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: "scale",
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        widget.blockModel.scale = double.tryParse(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
               
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scaleTextController.dispose();
    super.dispose();
  }
}

class PrintBlockWidget extends StatefulWidget {
  const PrintBlockWidget({super.key});

  @override
  State<PrintBlockWidget> createState() => _PrintBlockWidgetState();
}

class _PrintBlockWidgetState extends State<PrintBlockWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}


class VariableBlockWidget extends StatefulWidget {
  final VariableBlock blockModel;

  const VariableBlockWidget({super.key, required this.blockModel});

  @override
  State<VariableBlockWidget> createState() => _VariableBlockWidgetState();
}

class _VariableBlockWidgetState extends State<VariableBlockWidget> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  VariableType _selectedType = VariableType.integer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.blockModel.variableName);
    _valueController = TextEditingController(text: widget.blockModel.variableValue.toString());
    _selectedType = widget.blockModel.variableType;
  }

  void _validateAndSetValue(String value) {
    dynamic parsedValue;
    switch (_selectedType) {
      case VariableType.integer:
        parsedValue = int.tryParse(value);
        break;
      case VariableType.doubleType:
        parsedValue = double.tryParse(value);
        break;
      case VariableType.string:
        parsedValue = value;
        break;
      case VariableType.boolean:
        parsedValue = (value.toLowerCase() == 'true');
        break;
    }
    if (parsedValue == null && _selectedType != VariableType.string) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid value for type ${_selectedType.name}")),
      );
    } else {
      setState(() {
        widget.blockModel.variableValue = parsedValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var gameObjectManagerProvider = Provider.of<GameObjectManagerProvider>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(widget.blockModel.width, widget.blockModel.height),
          painter: BlockPainter(
            color: widget.blockModel.color,
            widthFactor: 1.0,
            heightFactor: 1.0,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    widget.blockModel.variableName = value;
                    gameObjectManagerProvider.addVariableValue(
                        variableName: value, value: widget.blockModel.variableValue);
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<VariableType>(
              value: _selectedType,
              onChanged: (newType) {
                if (newType != null) {
                  setState(() {
                    _selectedType = newType;
                    widget.blockModel.variableType = newType;
                    _validateAndSetValue(_valueController.text);
                  });
                }
              },
              items: VariableType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ))
                  .toList(),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Value",
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                  onChanged: _validateAndSetValue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}





class BlockPainter extends CustomPainter {
  final Color color;
  final double widthFactor; // Allow blocks to have different widths
  final double heightFactor; // Allow blocks to have different heights

  const BlockPainter({
    required this.color,
    this.widthFactor = 0.6, // Default width factor
    this.heightFactor = 0.3, // Default height factor
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3); // Light grey for visibility
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Dynamic width and height based on the size provided
    double width = size.width * widthFactor;
    double height = size.height * heightFactor;

    double left = (size.width - width) / 2;
    double top = (size.height - height) / 2;

    Rect rect = Rect.fromLTWH(left, top, width, height);
    Rect oval =
        Rect.fromCircle(center: Offset(size.width / 2, top), radius: 10);
    Rect indent = Rect.fromCircle(
        center: Offset(size.width / 2, top + height), radius: 10);

    Path path = Path()
      ..addRect(rect)
      ..addOval(oval);

    Path circlePath = Path()..addOval(indent);
    Path resultPath = Path.combine(PathOperation.difference, path, circlePath);

    canvas.drawPath(resultPath, paint);
  }

  @override
  bool shouldRepaint(covariant BlockPainter oldDelegate) =>
      oldDelegate.widthFactor != widthFactor ||
      oldDelegate.heightFactor != heightFactor ||
      oldDelegate.color != color;
}