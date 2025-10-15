import 'play.dart';

class Solo extends Play {
  Solo({
    required super.totalScore,
    required super.answers,
    required super.scores
  });

  Map<String, dynamic> toMap() => {
    'totalScore': totalScore,
    'answers': answers,
    'scores': scores
  };

  factory Solo.fromMap(Map<String, dynamic> map) => Solo(
    totalScore: (map['totalScore'] ?? 0).toDouble(),
    answers: Map<String, String>.from(map['answers'] ?? {}),
    scores: Map<String, double>.from(map['answers'] ?? {}),
  );
}
