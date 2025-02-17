import 'package:flutter/material.dart';
import 'package:scratch_clone/widgets/animationWidgets/animation_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/color_picker_panel.dart';
import 'package:scratch_clone/widgets/animationWidgets/eraser_button.dart';
import 'package:scratch_clone/widgets/animationWidgets/paint_button.dart';
import 'package:scratch_clone/widgets/animationWidgets/stroke_width_slider_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/time_line_widget.dart';
import 'package:scratch_clone/widgets/animationWidgets/tweening_slider.dart';

class AnimationEditorScreen extends StatelessWidget {
  const AnimationEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const Drawer(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TweeningSlider(),
            StrokeWidthSliderWidget(),
            ColorPickerPanel(),
            Row(
              children: [
                PaintButton(),
                SizedBox(
                  width: 10,
                ),
                EraserButton(),
              ],
            ),
          ],
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Animationwidget(),
            TimeLineWidget(),
            
            
          ],
        ),
      ),
    );
    
  }
}
