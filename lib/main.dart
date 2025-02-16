import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/providers/animationProviders/animation_controller_provider.dart';
import 'package:scratch_clone/providers/animationProviders/frame_provider.dart';
import 'package:scratch_clone/providers/animationProviders/sketch_provider.dart';
import 'package:scratch_clone/providers/blockProviders/block_state_provider.dart';
import 'package:scratch_clone/providers/gameObjectProviders/game_object_manager_provider.dart';
import 'package:scratch_clone/screens/main_screen.dart';
import 'package:scratch_clone/test_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BlockStateProvider()),
        ChangeNotifierProvider(create: (context) => FramesProvider()),
        ChangeNotifierProvider(create: (context) => GameObjectManagerProvider(vsync: this)),
        ChangeNotifierProvider(create: (context) => SketchProvider()),
        ChangeNotifierProvider(create: (context) => AnimationControllerProvider(this)),
      ],
      child: const MaterialApp(
        title: 'Scratch Clone',
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}