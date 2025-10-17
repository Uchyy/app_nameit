// game_play_base.dart
import 'package:nomino/helpers/game_provider.dart';
import 'package:nomino/main.dart';
import 'package:nomino/model/categories.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:provider/provider.dart';
import '../../misc/curved_button.dart';
import '../../misc/custom_keyboard.dart';
import '../../theme/colors.dart';

class GamePlayBase extends StatefulWidget {
  final String letter;
  final int minutes;
  final List<String> categories;
  final Function(Map<String, String>) onSubmit;
  //final VoidCallback onReset;

  const GamePlayBase({
    super.key,
    required this.letter,
    required this.minutes,
    required this.categories,
    required this.onSubmit,
    //required this.onReset,
  });

  @override
  State<GamePlayBase> createState() => _GamePlayBaseState();
}

class _GamePlayBaseState extends State<GamePlayBase> {
  late List<TextEditingController> _controllers;
  final _scrollController = ScrollController();
  late List<FocusNode> _focusNodes;
  late DateTime _endTime;
  bool _warn = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.categories.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.categories.length, (_) => FocusNode());
    _endTime = DateTime.now().add(Duration(minutes: widget.minutes));

    _revealFocused();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  void onReset() {
    for (final c in _controllers) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
            children: [
              // ===== Header: name + letter + timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("nomino",
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: GoogleFonts.modak().fontFamily,
                          color: const Color(0xFF717744),
                        )),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.letter,
                        style: TextStyle(
                          fontFamily: GoogleFonts.dancingScript().fontFamily,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    TimerCountdown(
                      enableDescriptions: false,
                      format: CountDownTimerFormat.minutesSeconds,
                      endTime: _endTime,
                      timeTextStyle: TextStyle(
                        fontFamily: GoogleFonts.playfair().fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _warn
                            ? AppColors.lightRed
                            : AppColors.primaryVariant,
                      ),
                      onTick: (remaining) {
                        if (!_warn && remaining.inSeconds <= 60) {
                          setState(() => _warn = true);
                        }
                      },
                      onEnd: () {
                        final answers = <String, String>{};
                        for (int i = 0; i < widget.categories.length; i++) {
                          answers[widget.categories[i]] =
                              _controllers[i].text.trim();
                        }
                        widget.onSubmit(answers);
                      },
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 2),

              // ===== Inputs
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: widget.categories.asMap().entries.map((entry) {
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
                                labelText: cat,
                                prefixIcon: Icon(getIconForCategory(cat)),
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

              // ===== Buttons
              CurvedButton(
                leftLabel: "RESET",
                rightLabel: "SUBMIT",
                onLeftPressed: onReset,
                onRightPressed: () {
                  final answers = <String, String>{};
                  for (int i = 0; i < widget.categories.length; i++) {
                    answers[widget.categories[i]] =
                        _controllers[i].text.trim();
                  }
                  widget.onSubmit(answers);
                },
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: screenSize.height * 0.31,
                child: CustomKeyboard(),
              ),
            ],
          ),
        ),
      ),
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
                MaterialPageRoute(builder: (context) => nomino()),
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
