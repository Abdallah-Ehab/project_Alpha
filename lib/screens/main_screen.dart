import 'package:flutter/material.dart';
import 'package:scratch_clone/constants/colors/colors.dart';
import 'package:scratch_clone/screens/animation_editor_screen.dart';
import 'package:scratch_clone/screens/block_screen.dart';
import 'package:scratch_clone/screens/game_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false; // Track drawer state

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      AnimationEditorScreen(onDrawerToggle: _toggleDrawer), // Pass control
      const GameScreen(),
      const BlocksScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleDrawer(bool isOpen) {
    setState(() {
      _isDrawerOpen = isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height
    double navbarHeight = screenHeight * 0.08; // Make navbar height responsive

    return Scaffold(
      body: _pages[_selectedIndex],

      // Animated Bottom Navigation Bar
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: _isDrawerOpen
            ? const SizedBox.shrink() // Hide navbar when drawer is open
            : Container(
                height: navbarHeight.clamp(90, 120), // Keep height between 60-90 pixels
                decoration: BoxDecoration(
                  color: MyColors.babyBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.edit),
                        label: 'Editor',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.play_arrow),
                        label: 'Game',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.extension),
                        label: "Blocks",
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: MyColors.pastelPeach,
                    unselectedItemColor: MyColors.coolGray,
                    backgroundColor: MyColors.deepBlue,
                    type: BottomNavigationBarType.fixed,
                    showUnselectedLabels: false,
                    elevation: 0,
                    onTap: _onItemTapped,
                  ),
                ),
              ),
      ),
    );
  }
}
