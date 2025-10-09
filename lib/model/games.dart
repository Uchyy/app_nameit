import 'dart:ffi';

class FirestoreGame {
  final String code;
  final String createdBy; // uid of creator
  final DateTime createdOn;
  final bool hasStarted;
  final bool hasEnded;
  final String selectedChar;
  final int duration;
  final List<String> playerIds;
  final List<String> selectedCategories;
  final Map<String, double> scores; // uid → score

  FirestoreGame({
    required this.code,
    required this.createdBy,
    required this.createdOn,
    required this.selectedChar,
    required this.duration,
    this.hasStarted = false,
    this.hasEnded = false,
    this.playerIds = const [],
    this.selectedCategories = const [],
    this.scores = const {},
  });

  Map<String, dynamic> toMap() => {
    'code': code,
    'createdBy': createdBy,
    'createdOn': createdOn.toIso8601String(),
    'hasStarted': hasStarted,
    'hasEnded': hasEnded,
    'selectedChar': selectedChar,
    'duration': duration,
    'playerIds': playerIds,
    'selectedCategories': selectedCategories,
    'scores': scores,
  };

  factory FirestoreGame.fromMap(Map<String, dynamic> map) => FirestoreGame(
    code: map['code'],
    createdBy: map['createdBy'],
    createdOn: DateTime.parse(map['createdOn']),
    hasStarted: map['hasStarted'] ?? false,
    hasEnded: map['hasEnded'] ?? false,
    selectedChar: map['selectedChar'],
    duration: map['duration'],
    playerIds: List<String>.from(map['playerIds'] ?? []),
    selectedCategories: List<String>.from(map['selectedCategories'] ?? []),
    scores: Map<String, double>.from(map['scores'] ?? {}),
  );
}
