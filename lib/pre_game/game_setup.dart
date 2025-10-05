import 'dart:ui';

import 'package:app_nameit/game_play/play_solo.dart';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:app_nameit/misc/game_setup_container.dart';
//import 'package:app_nameit/misc/generate_game_code.dart';
import 'package:app_nameit/pre_game/widgets/multiplayer_screen.dart';
import 'package:app_nameit/pre_game/widgets/select_category.dart';
import 'package:app_nameit/pre_game/widgets/select_char.dart';
import 'package:app_nameit/pre_game/widgets/select_duration.dart';
import 'package:app_nameit/pre_game/widgets/select_mode.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final game = Provider.of<GameProvider>(context, listen: false).game;
    final mode = game.mode.toLowerCase();
    final totalPages = (mode == "multiplayer") ? 4 : 3;

    if (_currentPage < totalPages) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GamePlayScreen(minutes: game.duration,)),
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
    final mode = Provider.of<GameProvider>(context, listen: false).game.mode.toLowerCase();
    final totalPages = (mode == "multiplayer") ? 5 : 4;
    final lastPage = totalPages - 1;

    if (_currentPage == lastPage) {
      return screenHeight * 0.95;
    }

    if (_currentPage == 1 && mode == "multiplayer") {
      return screenHeight * 0.58;
    }

    if (_currentPage == 2 && mode == "multiplayer") {
      return screenHeight * 0.53;
    }

    if (_currentPage == 1 && mode != "multiplayer") {
      return screenHeight * 0.53;
    }

    return screenHeight * 0.58;
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = _getHeight();
    final mode = context.watch<GameProvider>().game.mode;
    //final gameCode = generateUniqueGameCode();

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
                        icon: const Icon(Icons.arrow_back, size: 30,  color: Color.fromARGB(255, 236, 183, 10)),
                        onPressed: _previousPage,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // PageView and navigation
                Expanded(
                  child: PageView(
                    //key: ValueKey(mode),
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 199, 182, 109),
                        title: "SELECT MODE",
                        child: SelectGameMode(onNext: _nextPage),
                      ),
                      if (mode.toLowerCase() == "multiplayer")... [
                        GameSetupContainer(
                          borderColor: const Color.fromARGB(255, 178, 165, 106),
                          title: "MULTIPLAYER CHOICE",
                          child: MultiplayerChoice(onNext: _nextPage),
                        ),
                      ],
                      GameSetupContainer(
                        borderColor: const Color.fromARGB(255, 229, 213, 141),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 30, color: Color.fromARGB(255, 236, 183, 10)),
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
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

