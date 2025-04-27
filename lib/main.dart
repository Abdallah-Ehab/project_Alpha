import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_scene/add_components.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/ui_element/ui_element_manager.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> GameState()),
        ChangeNotifierProvider(create: (_) => UiElementManager()),
        ChangeNotifierProvider(create: (_) => EntityManager()),
        ChangeNotifierProvider(create: (context){
          final entityManager = Provider.of<EntityManager>(context, listen: false);
          return entityManager.activeEntity;
        }),
        
      ],
      child: const MaterialApp(
        home: AddComponents(),
      ),
    );
  }
}
