class TrainingJob {
  final String trainingId;
  final String userId;
  final String progress;
  final String subProgress;
  final String createdAt;
  final String lastUpdated;
  final String message;

  const TrainingJob({
    required this.trainingId,
    required this.userId,
    required this.progress,
    required this.subProgress,
    required this.createdAt,
    required this.lastUpdated,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'training_id': this.trainingId,
      'user_id': this.userId,
      'progress': this.progress,
      'subprogress': this.subProgress,
      'created_at': this.createdAt,
      'last_updated': this.lastUpdated,
      'message': this.message,
    };
  }

  factory TrainingJob.fromMap(Map<String, dynamic> map) {
    return TrainingJob(
      trainingId: map['training_id'] as String,
      userId: map['user_id'] as String,
      progress: map['progress'] as String,
      subProgress: map['subprogress'] as String,
      createdAt: map['created_at'] as String,
      lastUpdated: map['last_updated'] as String,
      message: map['message'] as String,
    );
  }
}
