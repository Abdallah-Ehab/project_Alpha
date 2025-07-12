import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';

import 'package:scratch_clone/entity/presentation/add_component_button.dart';
import 'package:scratch_clone/entity/presentation/add_to_prefabs_button.dart';
import 'package:scratch_clone/entity/presentation/control_panel.dart';
import 'package:scratch_clone/entity/presentation/create_entity_button.dart';
import 'package:scratch_clone/entity/presentation/entity_drop_down_button.dart';
import 'package:scratch_clone/game_scene/add_global_variable_button.dart';
import 'package:scratch_clone/game_scene/game_view.dart';
import 'package:scratch_clone/game_state/save_game.dart';
import 'package:scratch_clone/login_and_signup/presentation/cubit/authentacation_cubit.dart';
import 'package:scratch_clone/login_and_signup/presentation/login_screen.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_elements_layer.dart';

class GameScene extends StatelessWidget {
  const GameScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [EntitySelectorArrows()],
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
      ),

      drawer : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CreateEntityButton(),
            SizedBox(height: 20,),
            AddToPrefabsButton(),
            SizedBox(height: 20,),
            AddComponentButton(),
            SizedBox(height: 20,),
            AddUIElementButton(),
            SizedBox(height: 20,),
            AddVariableButton(),
            Spacer(),
            PixelArtButton(text: "log out", callback: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
            }, fontsize: 12),
            SizedBox(height: 20,),
            SaveGameButton()
        
          ],
        ),

      ),
      body: Column(
        children: [
          Expanded(
            flex:4,
            child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // GameView as the background, expanded to fill available space
                    const GameView(),
                    // UIElementsLayer on top of GameView
                    const UIElementsLayer()
                  ],
                ),
              ),
            ),
                  ),
          ),
          Expanded(
            flex:2,
            child: ControlPanel(), // Control panel at the bottom
          ),]
      ),
    );
  }
}