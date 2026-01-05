class TrainingData {
  final int trainingExamples;
  final String baseModel;
  final String language;
  final double wordErrorRate;
  final double baselineModelWER;
  final int utterancesInTrain;
  final int utterancesInDev;

  const TrainingData({
    required this.trainingExamples,
    required this.baseModel,
    required this.language,
    required this.wordErrorRate,
    required this.baselineModelWER,
    required this.utterancesInDev,
    required this.utterancesInTrain
  });
}
