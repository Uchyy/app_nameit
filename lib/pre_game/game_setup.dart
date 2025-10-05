import 'dart:ffi';
import 'dart:ui';

import 'package:app_nameit/game_play/play_solo.dart';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:app_nameit/misc/game_setup_container.dart';
import 'package:app_nameit/pre_game/widgets/select_category.dart';
import 'package:app_nameit/pre_game/widgets/select_char.dart';
import 'package:app_nameit/pre_game/widgets/select_duration.dart';
import 'package:app_nameit/pre_game/widgets/select_mode.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../theme/colors.dart';

class GameSetupScreen extends StatefulWidget{
  const GameSetupScreen({super.key});

  @override
  GameSetupScreenState createState() => GameSetupScreenState();
  
}

class GameSetupScreenState extends State<GameSetupScreen> with SingleTickerProviderStateMixin  {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List <GameModel> gameSetupWidgets = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GamePlayScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  double _getHeight() {
    final screenHeight = MediaQuery.of(context).size.height;
    switch (_currentPage) {
      case 1: // duration page
        return screenHeight * 0.43;
      case 3: // categories page
        return screenHeight * 0.75;
      default:
        return screenHeight * 0.5;
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = _getHeight();
    final game = context.watch<GameProvider>().game;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRect( // 👈 prevents overflow flash
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                // Custom header at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30),
                        onPressed: _previousPage,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // PageView and navigation
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 139, 196, 243),
                        title: "SELECT MODE",
                        child: SelectGameMode(onNext: _nextPage),
                      ),
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 249, 150, 180),
                        title: "SELECT DURATION",
                        child: SelectDuration(),
                      ),
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 153, 140, 80),
                        title: "SELECT CHARACTER",
                        child: SelectChar(),
                      ),
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 153, 140, 80),
                        title: "SELECT CATEGORIES",
                        child: SelectCategories(),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage == gameSetupWidgets.length - 1
                        ? const SizedBox.shrink()
                        : const Spacer(),
                    TextButton(
                      onPressed: _nextPage,
                      child: Text(
                        "Next   ",
                        style: TextStyle(
                          fontFamily: GoogleFonts.lato().fontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 25,
                          color: AppColors.primaryVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      )
    );
  }
    
}

class GameModel  {
  final String title;
  final Widget widget;

  GameModel ({
    required this.title,
    required this.widget,
  });
}

