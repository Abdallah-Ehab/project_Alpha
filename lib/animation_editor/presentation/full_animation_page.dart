
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/onin_skin_settings.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_editor_screen.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_track_control_panel.dart';
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
  State<FullAnimationEditorPage> createState() => _FullAnimationEditorPageState();
}

class _FullAnimationEditorPageState extends State<FullAnimationEditorPage>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
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
          create: (_)=>ToolSettings(),
        ),
        ChangeNotifierProvider(create: (_)=>OnionSkinSettings())
      ],
     
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Animation Editor"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Editor"),
              Tab(text: "Transitions"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.brush),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            )
          ],
          
        ),
        floatingActionButton: Consumer<EntityManager>(
          builder: (context, value, child) {
            final entity = EntityManager().activeEntity;
           return ChangeNotifierProvider.value(
            value: entity,
             child: Consumer<Entity>(
               builder: (context, value, child) =>  Column(
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
                      icon: const Icon(Icons.graphic_eq),
                      label: const Text("Visualize"),
                      heroTag: 'visualize',
                    ),
                    const SizedBox(height: 12),
                         
                    // Add button (at the bottom)
                    FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddAnimationTransitionDialog(entityName: entity.name),
                        );
                      },
                      heroTag: 'add',
                      child: const Icon(Icons.add),
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
              children: [
                const Expanded(flex: 20, child: AnimationEditorScreen()),
                const Expanded(flex:1,child: PlayBackControlPanel()),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      const Expanded(flex: 3, child: AnimationTrackControlPanel()),
                      Expanded(flex: 8, child: MyTimeline()),
                    ],
                  ),
                )
              ],
            ),
            const AnimationTransitionsPage(),
          ],
        ),
      ),
    );
  }
}