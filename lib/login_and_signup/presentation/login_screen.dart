import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'package:scratch_clone/game_scene/test_game_loop.dart';
import 'package:scratch_clone/game_state/load_game_page.dart';
import 'package:scratch_clone/login_and_signup/presentation/signUp_screen.dart';
import 'package:scratch_clone/login_and_signup/presentation/widgets/shooting_stars.dart';
import 'package:scratch_clone/main_screen_and_loading_projects/presentation/project_loading_Screens.dart';
import '../../core/ui_widgets/pixelated_buttons.dart';
import '../../core/ui_widgets/pixelated_text_feild.dart';

import 'cubit/authentacation_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoadProjectScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: "PressStart2P"),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              ShootingStarsBackground(),
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: "PressStart2P",
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const LottieAnimation(),
                          const SizedBox(height: 40),
                          PixelatedTextField(
                            hintText: "Username",
                            controller: _usernameController,
                            borderColor: Colors.white,
                            keyboardType: TextInputType.text,
                            onChanged: (String value) {},
                          ),
                          const SizedBox(height: 20),
                          PixelatedTextField(
                            hintText: "Password",
                            controller: _passwordController,
                            borderColor: Colors.white,
                            keyboardType: TextInputType.visiblePassword,
                            onChanged: (String value) {},
                          ),
                          const SizedBox(height: 30),
                          isLoading
                              ? const CircularProgressIndicator(color: Color(0xffcccccc),)
                              : PixelArtButton(
                                  fontsize: 14,
                                  text: "Login",
                                  callback: () {
                                    final username =
                                        _usernameController.text.trim();
                                    final password = _passwordController.text;

                                    if (username.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Username and password required",
                                            style: TextStyle(
                                                fontFamily: "PressStart2P"),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    context
                                        .read<AuthCubit>()
                                        .signIn(username, password);
                                  },
                                ),
                          SizedBox(
                            height: 60,
                          ),
                          NoAccountText(
                            highLightedText: 'SignUp',
                            text: 'No account ?! no problem make one now ',
                            onSignUpTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LottieAnimation extends StatefulWidget {
  const LottieAnimation({super.key});

  @override
  State<LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Lottie.asset(
          "assets/lottie/coin.json",
          repeat: true,
          animate: true,
        ),
      ),
    );
  }
}

class NoAccountText extends StatefulWidget {
  final VoidCallback onSignUpTap;
  final String text;
  final String highLightedText;

  const NoAccountText(
      {super.key,
      required this.onSignUpTap,
      required this.text,
      required this.highLightedText});

  @override
  State<NoAccountText> createState() => _NoAccountTextState();
}

class _NoAccountTextState extends State<NoAccountText> {
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()..onTap = widget.onSignUpTap;
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: widget.text,
        style: const TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 12,
          color: Colors.white70,
        ),
        children: [
          TextSpan(
            text: widget.highLightedText,
            style: const TextStyle(
                color: Colors.orange,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                height: 2),
            recognizer: _tapRecognizer,
          ),
        ],
      ),
    );
  }
}
