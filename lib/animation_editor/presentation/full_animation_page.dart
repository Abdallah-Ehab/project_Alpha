import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/animation_editor/data/tool_settings.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_editor_screen.dart';
import 'package:scratch_clone/animation_editor/presentation/animation_track_control_panel.dart';
import 'package:scratch_clone/animation_editor/presentation/play_back_control_panel.dart';
import 'package:scratch_clone/animation_editor/presentation/timeline.dart';
import 'package:scratch_clone/animation_editor/presentation/tool_palette.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ToolSettings(),
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
        endDrawer: const ToolPaletteDrawer(),
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                const Expanded(flex: 6, child: AnimationEditorScreen()),
                const Expanded(flex:2,child: PlayBackControlPanel()),
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
            const Center(child: Text("Transitions tab coming soon...")),
          ],
        ),
      ),
    );
  }
}