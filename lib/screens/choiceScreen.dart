import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/screens/main_screen.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.nightColor ,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Scratch Games",style: GoogleFonts.cinzel(color: MyColors.goldColor,fontSize: 40,fontWeight: FontWeight.bold,wordSpacing: 6,letterSpacing: 3 ),),
          ),
          const  SizedBox(
            height: 150,
          ),
          NightThemeButton(onTapDown: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  MainScreen(),));}, text: "Animation"),
          const  SizedBox(
            height: 50,
          ),
          NightThemeButton(onTapDown: () {}, text: "Game"),
        ],
      ),
    );
  }
}

class NightThemeButton extends StatefulWidget {
  final VoidCallback onTapDown;
  final String text;

  const NightThemeButton(
      {super.key, required this.onTapDown, required this.text});

  @override
  _NightThemeButtonState createState() => _NightThemeButtonState();
}

class _NightThemeButtonState extends State<NightThemeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180), // Release is slower
      reverseDuration: const Duration(milliseconds: 80), // Press is quicker
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _translateAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTapDown();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: screenWidth * 0.6,
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              decoration: BoxDecoration(
                color: const Color(0xff001F3F),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xffDAA520).withOpacity(0.8), // Golden glow
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xffDAA520), width: 2),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xffDAA520), // Gold text
                    fontSize: screenWidth * 0.06, // 6% of screen width
                    fontWeight: FontWeight.bold,
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
