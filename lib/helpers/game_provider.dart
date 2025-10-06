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
  void setAnswers(Map<String, String> answers) {
    _game.answers = Map<String, String>.from(answers);
    notifyListeners();
  }

  void resetGame() {
    _game = Game();
    notifyListeners();
  }
}
