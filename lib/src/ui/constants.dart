enum RouteNames {
  category,
  home,
  license,
  loading,
  firstpage,
  nahidastore,
  setting;

  String get name => '/${(this as Enum).name}';
}

enum RouteParams {
  category,
}

const protocol = 'gmm-interop-uri';
