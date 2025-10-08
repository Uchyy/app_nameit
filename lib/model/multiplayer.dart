import 'user.dart';
import 'play.dart';

class Multiplay extends Play {
  final String gameCode;
  final String markedBy; // user.uid
  final String markedWho; // user.uid

  Multiplay({
    required super.totalScore,
    required super.answers,
    required this.gameCode,
    required this.markedBy,
    required this.markedWho,
  });

  Map<String, dynamic> toMap() => {
    'totalScore': totalScore,
    'answers': answers,
    'gameCode': gameCode,
    'markedBy': markedBy,
    'markedWho': markedWho,
  };

  factory Multiplay.fromMap(Map<String, dynamic> map) => Multiplay(
    totalScore: (map['totalScore'] ?? 0).toDouble(),
    answers: Map<String, String>.from(map['answers'] ?? {}),
    gameCode: map['gameCode'],
    markedBy: map['markedBy'],
    markedWho: map['markedWho'],
  );
}
