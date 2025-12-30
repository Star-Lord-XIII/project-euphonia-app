class TrainingData {
  final int trainingExamples;
  final String baseModel;
  final String language;
  final double wordErrorRate;

  const TrainingData({
    required this.trainingExamples,
    required this.baseModel,
    required this.language,
    required this.wordErrorRate,
  });
}