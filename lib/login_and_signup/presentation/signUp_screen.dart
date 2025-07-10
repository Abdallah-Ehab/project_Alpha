import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/ui_widgets/pixelated_buttons.dart';
import '../../core/ui_widgets/pixelated_text_feild.dart';
import 'cubit/authentacation_cubit.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  void _signUp() {
    // final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if ( email.isEmpty || password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All fields are required',
            style: TextStyle(fontFamily: 'PressStart2P'),
          ),
        ),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match',
            style: TextStyle(fontFamily: 'PressStart2P'),
          ),
        ),
      );
      return;
    }
  log(email.toString());
    // Trigger signup via Cubit
    context.read<AuthCubit>().signUp(email, password);
  }

  @override
  void dispose() {

    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontFamily: "PressStart2P",
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      PixelatedTextField(
                        maxLength: 100,
                        hintText: "Email",
                        controller: _emailController,
                        borderColor: Colors.white,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String value) {},
                      ),
                      const SizedBox(height: 16),
                      PixelatedTextField(
                        maxLength: 100,
                        hintText: "Password",
                        controller: _passwordController,
                        borderColor: Colors.white,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (String value) {},
                      ),
                      const SizedBox(height: 16),
                      PixelatedTextField(
                        maxLength: 100,
                        hintText: "Confirm Password",
                        controller: _confirmController,
                        borderColor: Colors.white,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (String value) {},
                      ),
                      const SizedBox(height: 32),
                      PixelArtButton(
                        fontsize: 14,
                        text: "Create Account",
                        callback: _signUp,
                      ),
                      const SizedBox(height: 32),
                      NoAccountText(
                        highLightedText: "login",
                        text: "Already have an account?         ",
                        onSignUpTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            )),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
