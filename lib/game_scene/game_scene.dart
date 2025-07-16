import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/ui_widgets/pixelated_buttons.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/entity/presentation/add_component_button.dart';
import 'package:scratch_clone/entity/presentation/add_to_prefabs_button.dart';
import 'package:scratch_clone/entity/presentation/control_panel.dart';
import 'package:scratch_clone/entity/presentation/create_entity_button.dart';
import 'package:scratch_clone/entity/presentation/entity_drop_down_button.dart';
import 'package:scratch_clone/game_error.dart';
import 'package:scratch_clone/game_scene/add_global_variable_button.dart';
import 'package:scratch_clone/game_scene/game_view.dart';
import 'package:scratch_clone/game_state/save_game.dart';
import 'package:scratch_clone/login_and_signup/presentation/cubit/authentacation_cubit.dart';
import 'package:scratch_clone/login_and_signup/presentation/login_screen.dart';
import 'package:scratch_clone/ui_element/ui_button/presentation/add_ui_element_button.dart';
import 'package:scratch_clone/ui_element/ui_elements_layer.dart';

class GameScene extends StatefulWidget {
  const GameScene({super.key});

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  bool isPrefabExpanded = false;
  int _lastErrorCount = 0;
  bool isGlobalVariablesExpanded = false;
  @override
  Widget build(BuildContext context) {
    final entityManager = context.read<EntityManager>();
    final gameError = context.read<EntityManager>();
    return ChangeNotifierProvider.value(
      value: gameError,
      child:
          Consumer<GameErrorManager>(builder: (context, errorManager, child) {
        if (errorManager.errors.length > _lastErrorCount) {
          _lastErrorCount = errorManager.errors.length;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorToast(context, errorManager.errors.last);
          });
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [EntitySelectorArrows()],
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
          drawer: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CreateEntityButton(),
                SizedBox(
                  height: 20,
                ),
                AddToPrefabsButton(),
                SizedBox(
                  height: 20,
                ),
                AddComponentButton(),
                SizedBox(
                  height: 20,
                ),
                AddUIElementButton(),
                SizedBox(
                  height: 20,
                ),
                AddGlobalVariableButton(),
                SizedBox(height: 20),
                ChangeNotifierProvider.value(
                  value: entityManager,
                  child: Consumer<EntityManager>(
                    builder: (context, entityManager, child) => buildPrefabs(
                      title: "Prefabs",
                      prefabs: entityManager.prefabs,
                      isExpanded: isPrefabExpanded,
                      onToggle: () => setState(() {
                        isPrefabExpanded = !isPrefabExpanded;
                      }),
                    ),
                  ),
                ),
                ChangeNotifierProvider.value(
                  value: entityManager,
                  child: Consumer<EntityManager>(
                    builder: (context, value, child) {
                      return buildGlobalVariables(
                          title: 'glolab variables',
                          variables: entityManager.globalVariables,
                          isExpanded: isGlobalVariablesExpanded,
                          onToggle: () => setState(() {
                                isGlobalVariablesExpanded =
                                    !isGlobalVariablesExpanded;
                              }));
                    },
                  ),
                ),
                Spacer(),
                PixelArtButton(
                    text: "log out",
                    callback: () {
                      context.read<AuthCubit>().signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    },
                    fontsize: 12),
                SizedBox(
                  height: 20,
                ),
                SaveGameButton()
              ],
            ),
          ),
          body: Column(children: [
            Expanded(
              flex: 4,
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
              flex: 2,
              child: ControlPanel(), // Control panel at the bottom
            ),
          ]),
        );
      }),
    );
  }
}

Widget buildPrefabs({
  required String title,
  required Map<String, Entity> prefabs,
  required bool isExpanded,
  required VoidCallback onToggle,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Color(0xff555555),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: isExpanded,
            maintainState: true,
            maintainAnimation: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: prefabs.values.length,
              itemBuilder: (context, index) {
                final entry = (prefabs.values).toList()[index];
                return Draggable<Entity>(
                  data: entry,
                  feedback: Container(
                    color: Colors.blue,
                    child: Text(
                      entry.name,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDragStarted: () {
                    if (Scaffold.of(context).isDrawerOpen) {
                      Scaffold.of(context).closeDrawer();
                    }
                  },
                  child: ListTile(
                    title: Text(
                      entry.name,
                      style: const TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildGlobalVariables({
  required String title,
  required Map<String, dynamic> variables,
  required bool isExpanded,
  required VoidCallback onToggle,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Color(0xff555555),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Visibility(
            visible: isExpanded,
            maintainState: true,
            maintainAnimation: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: variables.keys.length,
              itemBuilder: (context, index) {
                final variableName = (variables.keys).toList()[index];
                return ListTile(
                  title: Text(
                    variableName,
                    style: const TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

void _showErrorToast(BuildContext context, GameError error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Node Execution Error',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error.message),
                if (error.node != null)
                  Text(
                    'Node: ${error.node!.id}',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}
