enum RouteNames {
  category,
  home,
  license,
  loading,
  nahidastore,
  setting;

  String get name => '/${(this as Enum).name}';
}
