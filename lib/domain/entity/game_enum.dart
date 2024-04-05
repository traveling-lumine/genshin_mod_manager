enum TargetGames {
  gshin(displayName: 'Genshin', prefix: ''),
  starrail(displayName: 'Starrail', prefix: 's_');

  const TargetGames({required this.displayName, required this.prefix});
  final String displayName;
  final String prefix;
}
