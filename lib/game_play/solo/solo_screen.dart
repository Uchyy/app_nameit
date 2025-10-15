// play_solo.dart
import 'package:app_nameit/game_play/widgets/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/game_provider.dart';
import 'result_screen.dart';
import '../../misc/page_loading.dart';

class SoloPlayScreen extends StatelessWidget {
  const SoloPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().game;
    final selectedCategories = game.categories.where((c) => c.isSelected).map((c) => c.name).toList();

    return GamePlayBase(
      letter: game.selectedChar,
      minutes: game.duration,
      categories: selectedCategories,
      onSubmit: (answers) {
        context.read<GameProvider>().setAnswers(answers);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PageLoading(
              first: "Checking dictionary...",
              second: "Validating answers...",
              third: "Calculating score",
              nextPage: ResultsScreen(),
            ),
          ),
        );
      },
    );
  }
}
