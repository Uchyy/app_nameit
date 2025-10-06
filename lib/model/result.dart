class Result {
  final Map<String, double> scores;
  final Map<String, String> remarks;
  final Map<String, String> answers;

  Result({
    required this.scores,
    required this.remarks,
    required this.answers,
  });

  double getTotal() => scores.values.fold(0.0, (a, b) => a + b);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('--- Result Summary ---');

    if (scores.isEmpty) {
      buffer.writeln('No answers found.');
    } else {
      scores.forEach((category, score) {
        final remark = remarks[category] ?? '';
        final answer = answers[category] ?? '';
        buffer.writeln(
          '$category → "$answer" | Score: ${score.toStringAsFixed(2)} | Remark: $remark',
        );
      });
    }

    buffer.writeln('Total Score: ${getTotal().toStringAsFixed(2)}');
    buffer.writeln('-----------------------');
    return buffer.toString();
  }

}