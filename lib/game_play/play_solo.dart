import 'package:app_nameit/game_play/validation_screen.dart';
import 'package:app_nameit/game_play/widgets/game_buttons.dart';
import 'package:app_nameit/misc/custom_keyboard.dart';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:app_nameit/model/categories.dart';
import 'package:app_nameit/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

class GamePlayScreen extends StatefulWidget {
  final int minutes;
  const GamePlayScreen({super.key, required this.minutes});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  late DateTime _endTime;
  bool _warn = false;

  @override
  void initState() {
    super.initState();
    final selectedCategories = context.read<GameProvider>().game.categories.where((c) => c.isSelected).toList();
    _focusNodes = List.generate(selectedCategories.length, (_) => FocusNode());
    _controllers = List.generate(selectedCategories.length, (_) => TextEditingController());
    _endTime = DateTime.now().add(Duration(minutes: widget.minutes));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ValidationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final game = context.watch<GameProvider>().game;
    final categories = context.watch<GameProvider>().game.categories.where((c) => c.isSelected).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // =========================
            // Row 1: appname - col - timer
            // =========================
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
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
                          style: TextStyle(
                            fontFamily: GoogleFonts.dancingScript().fontFamily,
                            color: AppColors.secondary,        
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),

                    ],
                  ),

                  TimerCountdown(
                    enableDescriptions: false,
                    format: CountDownTimerFormat.minutesSeconds,
                    endTime: _endTime,
                    timeTextStyle: TextStyle(
                      fontFamily: GoogleFonts.playfair().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _warn ? AppColors.lightRed : AppColors.primaryVariant, // normal → red
                    ),
                    onTick: (remaining) {
                      if (!_warn && remaining.inSeconds <= 60) {
                        setState(() => _warn = true);
                      }
                    },
                    onEnd: () {
                      setState(() => _warn = false); 
                      _onSubmit(context);
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
                padding: const EdgeInsets.all(7),
                child: Column(
                  children: categories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
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
            // Row 3: Buttons
            // =========================
            BottomActionRow(
              onReset: () {
                for (final c in _controllers) {
                  c.clear();
                }
              },
              onMiddlePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Middle button pressed")),
                );
              },
              onSubmit: () async {
                _onSubmit(context);
              },
            ),
            const SizedBox(height: 10,),

            // =========================
            // Row 4: Keyboard
            // =========================
            SizedBox(
              height: screenSize.height * 0.31,
              child: CustomKeyboard(),
            ),

          ],
        ),
      ),
    );
  }
}
