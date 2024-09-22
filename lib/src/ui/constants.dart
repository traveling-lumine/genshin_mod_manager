enum RouteNames {
  category,
  categoryHero,
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
  categoryHeroTag,
}

const protocol = 'gmm-interop-uri';
