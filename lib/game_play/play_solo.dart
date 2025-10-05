import 'package:app_nameit/misc/custom_keyboard.dart';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:app_nameit/model/categories.dart';
import 'package:app_nameit/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final selectedCategories = context.read<GameProvider>().game.categories.where((c) => c.isSelected).toList();
    _focusNodes = List.generate(selectedCategories.length, (_) => FocusNode());
    _controllers = List.generate(selectedCategories.length, (_) => TextEditingController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final game = context.watch<GameProvider>().game;
    final categories = context.watch<GameProvider>().game.categories.where((c) => c.isSelected).toList();;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column( // 👈 main column for 3 rows
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // =========================
            // Row 1: appname - col - timer
            // =========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'nomino',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: GoogleFonts.modak().fontFamily,
                      color: const Color(0xFF717744),
                      letterSpacing: 2.0,
                    ),
                  ),

                  Column(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,        
                        child: Text(
                          game.selectedChar,
                          style: const TextStyle(
                            color: AppColors.secondary,        
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      Text(
                        game.mode.toUpperCase(), 
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: GoogleFonts.comfortaa().fontFamily,
                          color: const Color(0xFF717744),
                          fontWeight: FontWeight.bold,
                        ), 
                      ),
                    ],
                  ),

                  TimerCountdown(
                    enableDescriptions: false,
                    format: CountDownTimerFormat.minutesSeconds,
                    endTime: DateTime.now().add(
                      Duration(minutes: game.duration),
                    ),
                    onEnd: () {
                      print("Timer finished");
                    },
                  ),
                ],
              ),
            ),

            const Divider(thickness: 2),

            // =========================
            // Row 2: Textfields (later PageView)
            // =========================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        onChanged: (val) => context.read<GameProvider>().setAnswer(cat.name, val),
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        showCursor: true,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: cat.name,
                          prefixIcon: Icon(getIconForCategory(cat.name)),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                )
              ),
            ),

            // =========================
            // Row 3: Keyboard
            // =========================
            SizedBox(
              height: screenSize.height * 0.28,
              child: CustomKeyboard(),
            ),

          ],
        ),
      ),
    );
  }
}
