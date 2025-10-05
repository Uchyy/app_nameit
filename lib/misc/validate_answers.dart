import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nameit/model/game_vars.dart';

class AnswerValidator {
  /// Base URL for word validation (Free Dictionary API)
  static const String _dictionaryApi =
      'https://api.dictionaryapi.dev/api/v2/entries/en/';

  /// Validates all answers and returns a map { categoryName: isValid }
  static Future<Map<String, bool>> validate(Game game) async {
    final Map<String, bool> results = {};
    final answers = game.answers;
    final letter = game.selectedChar.toUpperCase();
    final Set<String> seen = {};

    for (final entry in answers.entries) {
      final category = entry.key;
      final answer = entry.value.trim();

      bool isValid = true;

      // 1️⃣ Empty
      if (answer.isEmpty) {
        isValid = false;
      }

      // 2️⃣ Starts with selected letter
      else if (answer[0].toUpperCase() != letter) {
        isValid = false;
      }

      // 3️⃣ No duplicates
      else if (!seen.add(answer.toLowerCase())) {
        isValid = false;
      }

      // 4️⃣ Exists in dictionary (optional, async)
      else {
        final exists = await _wordExists(answer);
        if (!exists) isValid = false;
      }

      results[category] = isValid;
    }

    return results;
  }

  /// Returns true only if all answers are valid
  static Future<bool> allValid(Game game) async {
    final results = await validate(game);
    return !results.values.contains(false);
  }

  /// Checks if a word exists in dictionary API
  static Future<bool> _wordExists(String word) async {
    try {
      final res = await http.get(Uri.parse('$_dictionaryApi$word'));
      if (res.statusCode == 200) return true;

      // The API returns 404 for words that don't exist
      return false;
    } catch (e) {
      print('Dictionary check failed for "$word": $e');
      return true; // assume valid if API fails
    }
  }

  /// Calculates total score (e.g., +10 per valid answer)
  static Future<int> calculateScore(Game game) async {
    final results = await validate(game);
    int score = 0;

    for (final valid in results.values) {
      if (valid) score += 10;
    }

    return score;
  }
}
