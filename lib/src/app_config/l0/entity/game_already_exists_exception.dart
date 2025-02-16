class GameAlreadyExistsException implements Exception {
  const GameAlreadyExistsException(this.gameName);
  final String gameName;
}
