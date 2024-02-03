class NoCardData implements Exception {
  final String cause;
  NoCardData({required this.cause});
}

class InvalidAnswerList implements Exception {
  final String cause;
  InvalidAnswerList({required this.cause});
}

class TrainingRunNotLoaded implements Exception {
  final String cause;
  TrainingRunNotLoaded({required this.cause});
}
