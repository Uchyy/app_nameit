abstract class Play {
  final double totalScore;
  final Map<String, String> answers; // category → answer
  final Map<String, double> scores;

  Play({
    required this.totalScore,
    required this.answers,
    required this.scores
  });

 double getAverageScorePerAnswer() => totalScore / answers.length;
}
