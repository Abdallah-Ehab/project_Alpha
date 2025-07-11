import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/onin_skin_settings.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_editor_screen.dart';
import 'package:scratch_clone/animation_editor/presentation/play_back_control_panel.dart';
import 'package:scratch_clone/animation_editor/presentation/timeline.dart';
import 'package:scratch_clone/animation_editor/presentation/tool_palette.dart';
import 'package:scratch_clone/animation_feature/presentation/animation_transition_dialog.dart';
import 'package:scratch_clone/animation_feature/presentation/animation_transition_page.dart';
import 'package:scratch_clone/animation_feature/presentation/animation_transition_visualizer.dart';
import 'package:scratch_clone/entity/data/entity.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';

class FullAnimationEditorPage extends StatefulWidget {
  const FullAnimationEditorPage({super.key});

  @override
  State<FullAnimationEditorPage> createState() =>
      _FullAnimationEditorPageState();
}

class _FullAnimationEditorPageState extends State<FullAnimationEditorPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ToolSettings(),
        ),
        ChangeNotifierProvider(create: (_) => OnionSkinSettings())
      ],
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xff222222),
          title: const Text(
            "Animation Editor",
            style: TextStyle(
                fontFamily: "PressStart2P", fontSize: 16, color: Colors.white),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(
                "Editor",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "PressStart2P",
                  fontSize: 12,
                ),
              )),
              Tab(
                  child: Text(
                "Transitions",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "PressStart2P",
                  fontSize: 12,
                ),
              )),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.brush,
                color: Colors.white,
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
        ),
        floatingActionButton:
            Consumer<EntityManager>(builder: (context, value, child) {
          final entity = EntityManager().activeEntity;
          return ChangeNotifierProvider.value(
            value: entity,
            child: Consumer<Entity>(
              builder: (context, value, child) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Visualize button (on top)
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnimationTransitionVisualizer(),
                        ),
                      );
                    },
                    backgroundColor: Color(0xff333333),
                    icon: const Icon(Icons.graphic_eq, color: Colors.white),
                    label: const Text(
                      "Visualize",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "PressStart2P",
                        fontSize: 12,
                      ),
                    ),
                    heroTag: 'visualize',
                  ),
                  const SizedBox(height: 12),

                  // Add button (at the bottom)
                  FloatingActionButton(
                    
                    backgroundColor: Color(0xff333333),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddAnimationTransitionDialog(
                          entityName: entity?.name ?? '',
                        ),
                      );
                    },
                    heroTag: 'add',
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        endDrawer: const ToolPaletteDrawer(),
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(flex: 20, child: AnimationEditorScreen()),
                Expanded(
                    flex: 5,
                    child: Container(
                        color: Color(0xff222222),
                        child: PlayBackControlPanel())),
                Expanded(
                    flex: 8,
                    child: Container(
                        color: Color(0xff222222), child: MyTimeline())),
              ],
            ),
            const AnimationTransitionsPage(),
          ],
        ),
      ),
    );
  }
}
