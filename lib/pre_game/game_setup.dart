import 'dart:ui';

import 'package:app_nameit/account/main.dart';
import 'package:app_nameit/game_play/solo/solo_screen.dart';
import 'package:app_nameit/misc/page_loading.dart';
import 'package:app_nameit/game_play/multiplay/waiting_room.dart';
import 'package:app_nameit/helpers/generate_game_code.dart';
import 'package:app_nameit/main.dart';
import 'package:app_nameit/helpers/game_provider.dart';
import 'package:app_nameit/misc/game_setup_container.dart';
import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/pre_game/widgets/multiplayer_screen.dart';
import 'package:app_nameit/pre_game/widgets/select_category.dart';
import 'package:app_nameit/pre_game/widgets/select_char.dart';
import 'package:app_nameit/pre_game/widgets/select_duration.dart';
import 'package:app_nameit/pre_game/widgets/select_mode.dart';
import 'package:app_nameit/service/store_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameSetupScreen extends StatefulWidget{
  const GameSetupScreen({super.key});

  @override
  GameSetupScreenState createState() => GameSetupScreenState();
  
}

class GameSetupScreenState extends State<GameSetupScreen> with SingleTickerProviderStateMixin  {

  final PageController _pageController = PageController();
  final storeService = StoreImpl();
  final currentUser = FirebaseAuth.instance.currentUser;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    final game = Provider.of<GameProvider>(context, listen: false).game;
    final mode = game.mode.toLowerCase();
    final totalPages = (mode == "multiplayer") ? 4 : 3;

    if (_currentPage < totalPages) {
      _currentPage++;
      setState(() => _currentPage);
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (game.mode == "solo") {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PageLoading(
              second: 'Creating game session...', 
              third: 'Loading game.....', 
              first: 'Finalizing......', 
              nextPage: SoloPlayScreen(),  
            )),
          );

      } else {
        debugPrint ("ENTEREING MUKTPLYAER MODE");
        if (currentUser?.uid == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PageLoading(
              second: 'Validating user...', 
              third: 'User not signed in', 
              first: 'Rerouting', 
              nextPage: AccountScreen(),  
            )),
          );
        } 
        String code = await generateUniqueGameCode();
        List<String> categories = Provider.of<GameProvider>(context, listen: false)
          .game
          .categories
          .where((c) => c.isSelected)
          .map((c) => c.name)
          .toList();

        String uid = currentUser!.uid;
        
        //Adding game to firstore
        FirestoreGame firestoreGame = FirestoreGame(
          code: code, 
          createdBy: uid, 
          createdOn: DateTime.now(), 
          selectedChar: game.selectedChar , 
          duration: game.duration,
          selectedCategories: categories,
        );
        await storeService.createGame(firestoreGame);
        await storeService.updateGameFields('playerIds', uid, code);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PageLoading(
              first: "Creating game session...",
              second: "Adding you to the game...",
              third: "Loading waiting room...",
              nextPage: WaitingRoom(gameCode: code),
            ),
          ),
        );
      }
    }

  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      setState(() => _currentPage);
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Nomino()),
      );
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
      return screenHeight * 0.6;
    }

    if (_currentPage == 2 && mode == "multiplayer") {
      return screenHeight * 0.53;
    }

    if (_currentPage == 1 && mode != "multiplayer") {
      return screenHeight * 0.53;
    }
    return screenHeight * 0.6;
  }


  @override
  Widget build(BuildContext context) {
    //final screenHeight = _getHeight();
    final mode = context.watch<GameProvider>().game.mode;
    //final gameCode = generateUniqueGameCode();

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent, // Optional: add semi-transparent overlay
              ),
            ),
          ),
        ),

        // Foreground content
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: _getHeight(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 35, color: Color.fromARGB(255, 227, 100, 100)),
                            onPressed: _previousPage,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          GameSetupContainer(
                            borderColor: const Color.fromARGB(255, 199, 182, 109),
                            title: "SELECT MODE",
                            child: SelectGameMode(onNext: _nextPage),
                          ),
                          if (mode.toLowerCase() == "multiplayer")
                            GameSetupContainer(
                              borderColor: const Color.fromARGB(255, 178, 165, 106),
                              title: "MULTIPLAYER CHOICE",
                              child: MultiplayerChoice(onNext: _nextPage),
                            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,),
                      child: Center(
                        child: IconButton(
                          alignment: Alignment.center,
                          icon: const Icon(Icons.arrow_forward, size: 35, color:  Color.fromARGB(255, 164, 72, 235)),
                          onPressed: _nextPage,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

  }
    
}


