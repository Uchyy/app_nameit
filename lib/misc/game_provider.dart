import 'package:app_nameit/misc/validate_answers.dart';
import 'package:app_nameit/model/categories.dart';
import 'package:app_nameit/model/game_vars.dart';
import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
   Game _game = Game(categories: getCategories());
  Game get game => _game;

  void setMode(String mode) {
    _game.mode = mode;
    notifyListeners();
  }

  void setDuration(int duration) {
    _game.duration = duration;
    notifyListeners();
  }

  void setCategories(List<GameCategory> categories) {
    _game.categories = categories;
    notifyListeners();
  }

  void toggleCategory(GameCategory category) {
    final selectedCount = _game.categories.where((c) => c.isSelected).length;

    if (category.isSelected) {
      category.isSelected = false; // unselect
    } else if (selectedCount < 6) {
      category.isSelected = true; // select if under limit
    }
    notifyListeners();
  }

  void setSelectedChar(String char) {
    _game.selectedChar = char;
    notifyListeners();
  }

/*
  void setMultiplayer(List<String> players) {
    _game.multiplayer = players;
    notifyListeners();
  }
 */ 
  void setAnswer(String category, String answer) {
  _game.answers = Map.from(_game.answers)..[category] = answer;
  notifyListeners();
}

  void resetGame() {
    _game = Game();
    notifyListeners();
  }

  Future<void> checkAnswers() async {
    final results = await AnswerValidator.validate(_game);
    final allValid = !results.values.contains(false);
    final score = await AnswerValidator.calculateScore(_game);

    if (allValid) {
      print("✅ All answers valid! Score: $score");
    } else {
      for (var entry in results.entries) {
        if (!entry.value) {
          print("❌ ${entry.key}: '${_game.answers[entry.key]}' is invalid");
        }
      }
      print("Total Score: $score");
    }
  }
}
