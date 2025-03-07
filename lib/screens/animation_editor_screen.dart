import 'package:flutter/material.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/widgets/animationWidgets/add_sprite_button.dart';
import 'package:scratch_clone/widgets/animationWidgets/animation_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/color_picker_panel.dart';
import 'package:scratch_clone/widgets/animationWidgets/eraser_button.dart';
import 'package:scratch_clone/widgets/animationWidgets/paint_button.dart';
import 'package:scratch_clone/widgets/animationWidgets/stroke_width_slider_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/time_line_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/tweening_slider.dart';

class AnimationEditorScreen extends StatefulWidget {
  final Function(bool) onDrawerToggle;

  const AnimationEditorScreen({super.key, required this.onDrawerToggle});

  @override
  State<AnimationEditorScreen> createState() => _AnimationEditorScreenState();
}

class _AnimationEditorScreenState extends State<AnimationEditorScreen> {
  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      widget.onDrawerToggle(_isDrawerOpen);
    });
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
      widget.onDrawerToggle(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main UI
          const SafeArea(
            child: Column(
              children: [
                Animationwidget(),
                TimeLineWidget(),
              ],
            ),
          ),

          // Background overlay when drawer is open
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _closeDrawer,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isDrawerOpen ? 0.4 : 0.0,
                child: Container(color: Colors.black),
              ),
            ),

          // Animated Drawer with Bubbly Design
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isDrawerOpen ? 0 : -260, // Moves in and out smoothly
            top: 0,
            bottom: 0,
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: MyColors.deepBlue, // Soft pastel peach
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 4,
                    offset: const Offset(3, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Tools",
                        style: TextStyle(
                          color: MyColors.pastelPeach,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                          color: MyColors.pastelPeach.withOpacity(0.1),
                          thickness: 1),
                      const TweeningSlider(),
                      Divider(
                          color: MyColors.pastelPeach.withOpacity(0.1),
                          thickness: 1),
                      const StrokeWidthSliderWidget(),
                      const ColorPickerPanel(),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PaintButton(),
                          SizedBox(width: 12),
                          EraserButton(),
                        ],
                      ),
                      const AddSpriteButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Button to Open Drawer
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDrawer,
        backgroundColor: MyColors.deepBlue, // Soft baby blue
        child: Icon(
          _isDrawerOpen ? Icons.close : Icons.draw, // Change icon when open
          color: MyColors.pastelPeach,
        ),
      ),
    );
  }
}
