import 'package:app_nameit/main.dart';
import 'package:app_nameit/misc/curved_button.dart';
import 'package:app_nameit/pre_game/game_setup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_nameit/helpers/game_provider.dart';
import 'package:app_nameit/helpers/validate_answers.dart';
import 'package:app_nameit/model/result.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _loading = true;
  Result? _result;
  String _remarkText = "";

  @override
  void initState() {
    super.initState();
    _processResults();
  }

  Future<void> _processResults() async {
    final game = context.read<GameProvider>().game;
    debugPrint(game.toString());

    // 1️⃣ Simulate a short delay for realism (like "Checking...")
    await Future.delayed(const Duration(seconds: 1));

    // 2️⃣ Get result from validator
    final result = await AnswerValidator.scoreAnswers(game);
    debugPrint("RESULTS - ${result.toString()}");
    final totalScore = result.getTotal();
    final rating = _scoreToText(totalScore, result.scores.length);

    setState(() {
      _result = result;
      _remarkText = rating;
      _loading = false;
    });
  }

  /// Converts numeric score to textual rating
  String _scoreToText(double total, int totalQs) {
    if (totalQs <= 0) return "No questions";
    final ratio = (total / totalQs).clamp(0.0, 1.0);

    if (ratio == 0.0) return "No valid answers";
    if (ratio < 0.3) return "Poor";
    if (ratio < 0.6) return "Fair";
    if (ratio < 0.75) return "Average";
    if (ratio < 0.9) return "Good";
    return "Excellent";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      body: _loading
        ? _buildLoading()
        : _result == null
          ? const Center(child: Text("No results found"))
          : _buildResults(),
    );
  }

  /// 1️⃣ Loading Progress View
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF717744)),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              "Validating answers...",
              key: ValueKey(DateTime.now().millisecondsSinceEpoch),
              style: TextStyle(
                fontSize: 18,
                fontFamily: GoogleFonts.lato().fontFamily,
                color: const Color(0xFF717744),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2️⃣ Final Results View
  Widget _buildResults() {
    final result = _result!;
    final total = result.getTotal();
    final totalQs = result.scores.length;
    final ratio = (total / totalQs).clamp(0.0, 1.0);
    final provider = context.read<GameProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Text(
            "Your Score",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.lato().fontFamily,
              color: const Color(0xFF373D20),
            ),
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ratio > 0.75
                        ? Colors.green
                        : (ratio > 0.5 ? Colors.orange : Colors.redAccent),
                  ),
                ),
              ),
              Text(
                "${(ratio * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _remarkText,
            style: TextStyle(
              fontSize: 22,
              fontFamily: GoogleFonts.comfortaa().fontFamily,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF717744),
            ),
          ),
          const SizedBox(height: 20),

          // Category breakdown
          Expanded(
            child: ListView(
              children: result.scores.entries.map((entry) {
                final cat = entry.key;
                final score = entry.value;
                final remark = result.remarks[cat] ?? "";
                final ans = result.answers[cat] ?? "";

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: score >= 1.0
                          ? Colors.green
                          : (score >= 0.5 ? Colors.orange : Colors.redAccent),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      cat.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.lato().fontFamily,
                      ),
                    ),
                    subtitle: Text(
                      "$ans\n$remark",
                      style: const TextStyle(height: 1.4),
                    ),
                    trailing: Text(
                      "${(score * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: score >= 1.0
                            ? Colors.green
                            : (score >= 0.5
                                ? Colors.orange
                                : Colors.redAccent),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
            ),
          ),

          // Button to replay
          const SizedBox(height: 10),
          CurvedButton(
            leftLabel: "PLAY AGAIN",
            rightLabel: "QUIT",
            onLeftPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => const GameSetupScreen(),
              ));
              provider.resetGame();
            },
            onRightPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Nomino()),
              );
              provider.resetGame();
            },
          ),
          const SizedBox(height: 40,)
        ],
      ),
    );
  }

  
}
