import 'package:app_nameit/game_play/validation_screen.dart';
import 'package:app_nameit/main.dart';
import 'package:app_nameit/misc/curved_button.dart';
import 'package:app_nameit/misc/custom_keyboard.dart';
import 'package:app_nameit/helpers/game_provider.dart';
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
  final _scrollController = ScrollController();

  late DateTime _endTime;
  bool _warn = false;

  @override
  void initState() {
    super.initState();
    final selectedCategories = context.read<GameProvider>().game.categories.where((c) => c.isSelected).toList();
    _focusNodes = List.generate(selectedCategories.length, (_) => FocusNode());
    _controllers = List.generate(selectedCategories.length, (_) => TextEditingController());
    _endTime = DateTime.now().add(Duration(minutes: widget.minutes));

    _revealFocused();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    final gameProvider = context.read<GameProvider>();
    final game = gameProvider.game;
    final categories = game.categories.where((c) => c.isSelected).toList();

    final Map<String, String> updatedAnswers = {};
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final controller = _controllers[i];
      updatedAnswers[category.name] = controller.text.trim();
    }
    context.read<GameProvider>().setAnswers(updatedAnswers);
    debugPrint("📝 Collected Answers: $updatedAnswers");

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

     return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _showExitDialog(context);
        if (exit && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
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
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cat = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Focus(
                            onFocusChange: (hasFocus) { if (hasFocus) _revealFocused(); },
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              showCursor: true,
                              readOnly: true, // using custom keyboard
                              decoration: InputDecoration(
                                labelText: cat.name,
                                prefixIcon: Icon(getIconForCategory(cat.name)),
                                border: const OutlineInputBorder(),
                              ),
                              onTap: _revealFocused, // optional, feels nice
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        );
                      }).toList(),
                    )

                  )
                ),
              ),

              // =========================
              // Row 3: Buttons
              // =========================
              CurvedButton(
                leftLabel: "RESET",
                rightLabel: "SUBMIT",
                onLeftPressed: () {
                  for (final c in _controllers) {
                    c.clear();
                  }
                },
                onRightPressed: () {
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
      )
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final provider = context.read<GameProvider>();
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        alignment: Alignment.center,
        title: const Center(
          child: Text(
            "Are you sure?",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: const Text(
          "You will lose all progress.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center, // 👈 centers buttons
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () { 
              provider.resetGame();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Nomino()),
              );
            },
            child: const Text("Exit"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // optional: softer edges
        ),
      ),
    ) ?? false;
  }

  void _revealFocused() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = FocusManager.instance.primaryFocus?.context;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: 0.1, // keep a bit of space above
        );
      }
    });
  }

}
