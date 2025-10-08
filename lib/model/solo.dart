import 'play.dart';

class Solo extends Play {
  Solo({
    required super.totalScore,
    required super.answers,
  });

  Map<String, dynamic> toMap() => {
    'totalScore': totalScore,
    'answers': answers,
  };

  factory Solo.fromMap(Map<String, dynamic> map) => Solo(
    totalScore: (map['totalScore'] ?? 0).toDouble(),
    answers: Map<String, String>.from(map['answers'] ?? {}),
  );
}
