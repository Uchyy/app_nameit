import 'package:app_nameit/game_play/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_nameit/misc/validate_answers.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  double _progress = 0.0;
  String _statusText = "Validating answers...";

  @override
  void initState() {
    super.initState();
    _runValidation();
  }

  Future<void> _runValidation() async {
    final provider = context.read<GameProvider>();

    // Step 1
    setState(() {
      _progress = 0.3;
      _statusText = "Checking dictionary...";
    });
    await Future.delayed(const Duration(seconds: 1));

    // Step 2
    setState(() {
      _progress = 0.6;
      _statusText = "Calculating score...";
    });
    await Future.delayed(const Duration(seconds: 1));

    // Actual validation logic
    final results = await AnswerValidator.validate(provider.game);
    final score = await AnswerValidator.calculateScore(provider.game);

    // Step 3
    setState(() {
      _progress = 1.0;
      _statusText = "Done!";
    });

    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to results page
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(results: results, score: score),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_statusText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: LinearProgressIndicator(value: _progress),
            ),
          ],
        ),
      ),
    );
  }
}
