import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_nameit/model/game_vars.dart';
import 'package:app_nameit/model/result.dart';

class AnswerValidator {
  static const String _dictionaryApi =
      'https://api.dictionaryapi.dev/api/v2/entries/en/';

  /// Validates and scores all answers → returns a full [Result]
  static Future<Result> scoreAnswers(Game game) async {
    final Map<String, double> scores = {};
    final Map<String, String> remarks = {};
    final answers = game.answers;
    final letter = game.selectedChar.toUpperCase();

    for (final entry in answers.entries) {
      final category = entry.key;
      final answer = entry.value;
      double score = 0.0;

      if (answer.isEmpty) {
        scores[category] = 0.0;
        remarks[category] = "❌ Empty";
        continue;
      }

      if (answer[0].toUpperCase() != letter) {
        scores[category] = 0.0;
        remarks[category] = "❌ Wrong starting letter";
        continue;
      }

      // 1️⃣ Dictionary existence → +0.5
      final exists = await _wordExists(answer);
      if (exists) {
        score += 0.5;
        remarks[category] = "✅ Word found";
      } else {
        remarks[category] = "⚠️ Not in dictionary";
      }

      // 2️⃣ Category-based score → +0.5
      final catScore = await _scoreByCategory(category, answer);
      score += catScore;

      // Cap to 1.0
      if (score > 1.0) score = 1.0;
      scores[category] = score;

      // Update remarks to reflect category validation
      if (catScore > 0 && exists) {
        remarks[category] = "✅ Correct ($score/1)";
      } else if (catScore > 0) {
        remarks[category] = "🟡 Partial credit ($score/1)";
      }
    }

    return Result(
      scores: scores,
      remarks: remarks,
      answers: Map<String, String>.from(answers),
    );
  }

  /// Simple dictionary existence check
  static Future<bool> _wordExists(String word) async {
    try {
      final res = await http.get(Uri.parse('$_dictionaryApi$word'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Category-specific checks → returns 0.0 or 0.5
  static Future<double> _scoreByCategory(String category, String answer) async {
    switch (category.toLowerCase()) {
      case 'animal':
        return await _isAnimal(answer) ? 0.5 : 0.0;
      case 'country':
        return await _isCountry(answer) ? 0.5 : 0.0;
      case 'food':
        return await _isFood(answer) ? 0.5 : 0.0;
      case 'movie':
        return await _isMovie(answer) ? 0.5 : 0.0;
      default:
        return 0.5;
    }
  }

  // ===== Optional category APIs =====
  static Future<bool> _isAnimal(String name) async {
    try {
      final res = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/animals?name=$name'),
        headers: {'X-Api-Key': 'YOUR_API_KEY'},
      );
      return res.statusCode == 200 && res.body.isNotEmpty && res.body != '[]';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isCountry(String name) async {
    try {
      final res = await http.get(Uri.parse('https://restcountries.com/v3.1/name/$name'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isFood(String name) async {
    try {
      final res = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$name'));
      return res.statusCode == 200 && res.body.contains(name);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _isMovie(String name) async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/search/movie?query=$name&api_key=YOUR_TMDB_KEY'));
      return res.statusCode == 200 && res.body.contains('results');
    } catch (_) {
      return false;
    }
  }
}
