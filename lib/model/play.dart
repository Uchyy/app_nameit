abstract class Play {
  final double totalScore;
  final Map<String, String> answers; // category → answer

  Play({
    required this.totalScore,
    required this.answers,
  });

 double getAverageScorePerAnswer() => totalScore / answers.length;
}
