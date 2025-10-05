import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, bool> results;
  final int score;

  const ResultScreen({super.key, required this.results, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score: $score",
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...results.entries.map((e) => Text(
                    "${e.key}: ${e.value ? '✅' : '❌'}",
                    style: TextStyle(
                      fontSize: 18,
                      color: e.value ? Colors.green : Colors.red,
                    ),
                  )),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
