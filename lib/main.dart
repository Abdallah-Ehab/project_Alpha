import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scratch_clone/core/api_keys.dart';
import 'package:scratch_clone/entity/data/entity_manager.dart';
import 'package:scratch_clone/game_state/game_state.dart';
import 'package:scratch_clone/login_and_signup/presentation/cubit/authentacation_cubit.dart';
import 'package:scratch_clone/login_and_signup/presentation/lottie-screen.dart';
import 'package:scratch_clone/node_feature/data/node_component_index_provider.dart';
import 'package:scratch_clone/node_feature/domain/connection_provider.dart';
import 'package:scratch_clone/ui_element/ui_element_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_and_signup/presentation/cubit/storage_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: ApiKeys.url, anonKey: ApiKeys.anon_key, debug: true);
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => UiElementManager()),
        ChangeNotifierProvider(create: (_) => EntityManager()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => NodeComponentIndexProvider(0)),
        ChangeNotifierProvider(create: (context) {
          final entityManager =
              Provider.of<EntityManager>(context, listen: false);
          return entityManager.activeEntity;
        }),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(Supabase.instance.client),
          ),
          BlocProvider(
            create: (context) => StorageCubit(),
          ),
        ],

        child: const MaterialApp(
          home: GamepadScreen(),
        ),
      ),
    );
  }
}
