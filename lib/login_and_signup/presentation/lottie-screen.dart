import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:scratch_clone/login_and_signup/presentation/cubit/authentacation_cubit.dart';
import 'package:scratch_clone/login_and_signup/presentation/login_screen.dart';
import 'package:scratch_clone/main_screen_and_loading_projects/presentation/project_loading_Screens.dart';

class GamepadScreen extends StatefulWidget {
  const GamepadScreen({super.key});

  @override
  State<GamepadScreen> createState() => _GamepadScreenState();
}

class _GamepadScreenState extends State<GamepadScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleState(context.read<AuthCubit>().state);
    });
  }

  void _handleState(AuthState state) {
    if (state is Authenticated) {
      _goTo(LoadProjectScreen());
    } else if (state is Unauthenticated) {
      _goTo(LoginScreen());
    }
  }

  void _goTo(Widget page) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _handleState(state),
      child: Scaffold(
        backgroundColor: const Color(0xff222222),
        body: Center(
          child: Lottie.asset(
            height: 200,
            width: 200,
            
            "assets/lottie/joy_stick.json",
            repeat: true,
            animate: true,
          ),
        ),
      ),
    );
  }
}






  