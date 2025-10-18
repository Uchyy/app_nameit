import 'dart:ui';

import 'package:nomino/account/main.dart';
import 'package:nomino/game_play/solo/solo_screen.dart';
import 'package:nomino/helpers/validate_code.dart';
import 'package:nomino/misc/custom_snackbar.dart';
import 'package:nomino/misc/page_loading.dart';
import 'package:nomino/game_play/multiplay/waiting_room.dart';
import 'package:nomino/helpers/generate_game_code.dart';
import 'package:nomino/main.dart';
import 'package:nomino/helpers/game_provider.dart';
import 'package:nomino/misc/game_setup_container.dart';
import 'package:nomino/model/games.dart';
import 'package:nomino/pre_game/widgets/multiplayer_screen.dart';
import 'package:nomino/pre_game/widgets/select_category.dart';
import 'package:nomino/pre_game/widgets/select_char.dart';
import 'package:nomino/pre_game/widgets/select_duration.dart';
import 'package:nomino/pre_game/widgets/select_mode.dart';
import 'package:nomino/service/store_impl.dart';
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
    final provider = Provider.of<GameProvider>(context, listen: false);
    final game = provider.game;
    final mode = game.mode.toLowerCase();

    // total steps = 5 if multiplayer (0–4), else 4 if solo (0–3)
    final totalSteps = (mode == "multiplayer") ? 5 : 4;

    if (mode == "multiplayer" && _currentPage == 1) {
      if (provider.isJoining) {
        final code = provider.joinCode;
        final isValid = await validateJoinCode(context, code);
        if (!isValid) return; // stop progress if invalid
      } else {
        debugPrint("Creating a new multiplayer game...");
      }
    }
  
    if (_currentPage < totalSteps - 1) {
      // just go to the next step (no PageView animation)
      setState(() => _currentPage++);
      return;
    }

    // 🚀 We're at the final step, start the game logic
    if (mode == "solo") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PageLoading(
            second: 'Creating game session...',
            third: 'Loading game.....',
            first: 'Finalizing......',
            nextPage: SoloPlayScreen(),
          ),
        ),
      );
    } else {
      debugPrint("ENTERING MULTIPLAYER MODE");

      if (currentUser?.uid == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PageLoading(
              second: 'Validating user...',
              third: 'User not signed in',
              first: 'Rerouting',
              nextPage: AccountScreen(),
            ),
          ),
        );
        return;
      }

      // create multiplayer game
      final code = await generateUniqueGameCode();
      final categories = Provider.of<GameProvider>(context, listen: false)
          .game
          .categories
          .where((c) => c.isSelected)
          .map((c) => c.name)
          .toList();

      final uid = currentUser!.uid;

      final firestoreGame = FirestoreGame(
        code: code,
        createdBy: uid,
        createdOn: DateTime.now(),
        selectedChar: game.selectedChar,
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

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Nomino()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<GameProvider>().game.mode;

    return Stack(
      children: [
        // 🔹 Blurred background
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // 🔹 Foreground bottom panel
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 35, color: Color(0xFFE46C5D)),
                                onPressed: _previousPage,
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),

                        // Dynamic step
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: _buildStep(_currentPage, mode),
                        ),

                        // Footer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Center(
                            child: IconButton(
                              alignment: Alignment.center,
                              icon: const Icon(Icons.arrow_forward, size: 35, color: Color(0xFF8A6FB3)),
                              onPressed: _nextPage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
}

  Widget _buildStep(int index, String mode) {
    final isMulti = mode.toLowerCase() == "multiplayer";

    if (index == 0) {
      return GameSetupContainer(
        key: const ValueKey('mode'),
        borderColor: const Color(0xFF8A6FB3),
        title: "SELECT MODE",
        icon: Icons.sports_esports,
        child: SelectGameMode(onNext: _nextPage),
      );
    }

    if (isMulti) {
      switch (index) {
        case 1:
          return GameSetupContainer(
            key: const ValueKey('multiplayer'),
            borderColor: const Color(0xFFE46C5D),
            title: "MULTIPLAYER CHOICE",
            icon: Icons.group_add,
            // scroll when keyboard shows
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: MultiplayerChoice(onNext: _nextPage),
            ),
          );
        case 2:
          return GameSetupContainer(
            key: const ValueKey('duration'),
            borderColor: const Color(0xFFE2B96A),
            title: "SELECT DURATION",
            icon: Icons.hourglass_top,
            child: SelectDuration(),
          );
        case 3:
          return GameSetupContainer(
            key: const ValueKey('char'),
            borderColor: const Color(0xFF4FC7C0),
            title: "SELECT CHARACTER",
            icon: Icons.abc,
            child: const SelectChar(),
          );
        case 4:
        default:
          return GameSetupContainer(
            key: const ValueKey('categories'),
            borderColor: const Color(0xFF3C90E8),
            title: "SELECT CATEGORIES",
            icon: Icons.category,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: const SelectCategories(),
            ),
          );
      }
    } else {
      // SOLO flow (no multiplayer step)
      switch (index) {
        case 1:
          return GameSetupContainer(
            key: const ValueKey('duration'),
            borderColor: const Color(0xFFE2B96A),
            title: "SELECT DURATION",
            icon: Icons.hourglass_top,
            child: SelectDuration(),
          );
        case 2:
          return GameSetupContainer(
            key: const ValueKey('char'),
            borderColor: const Color(0xFF4FC7C0),
            title: "SELECT CHARACTER",
            icon: Icons.abc,
            child: const SelectChar(),
          );
        case 3:
        default:
          return GameSetupContainer(
            key: const ValueKey('categories'),
            borderColor: const Color(0xFF3C90E8),
            title: "SELECT CATEGORIES",
            icon: Icons.category,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: const SelectCategories(),
            ),
          );
      }
    }
  }   
}


