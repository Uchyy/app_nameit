import 'package:app_nameit/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_nameit/theme/colors.dart'; // 👈 your app's color file

class MultiplayResult extends StatefulWidget {
  final double score; // raw score (out of 6)
  final String letter;
  final String gameCode;

  const MultiplayResult({
    super.key,
    required this.score,
    required this.letter,
    required this.gameCode,
  });

  @override
  State<MultiplayResult> createState() => _MultiplayResultState();
}

class _MultiplayResultState extends State<MultiplayResult> {
  final _db = FirebaseFirestore.instance;
  double? _averageScore;

  @override
  void initState() {
    super.initState();
    _fetchAverageScore();
  }

  /// Fetches the average score from games/{code}/scores map
  Future<void> _fetchAverageScore() async {
    try {
      final doc = await _db.collection('games').doc(widget.gameCode).get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null || data['scores'] == null) return;

      final scoresMap = Map<String, dynamic>.from(data['scores']);
      if (scoresMap.isEmpty) return;

      double total = 0;
      for (final s in scoresMap.values) {
        if (s is num) total += s.toDouble();
      }

      setState(() {
        _averageScore = total / scoresMap.length;
      });
    } catch (e) {
      debugPrint("❌ Error fetching average score: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = (widget.score / 6) * 100;
    final _avrgPercentage = (_averageScore! / 6) * 100; 
    final Color bgColor = percentage >= 80
        ? AppColors.lightRed
        : percentage >= 50
            ? AppColors.secondary
            : AppColors.lightRed;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Round Complete!",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.letter,
                      style: GoogleFonts.dancingScript(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    percentage >= 80
                        ? "Excellent!"
                        : percentage >= 50
                            ? "Nice effort!"
                            : "Keep practicing!",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                 // if (_avrgPercentage != null) ...[
                    const SizedBox(height: 25),
                    Divider(color: Colors.white70, thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      "Average Score",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "${_avrgPercentage.toStringAsFixed(1)}%",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                 // ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Nomino()),
                      );
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
