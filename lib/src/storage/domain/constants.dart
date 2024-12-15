enum StorageAccessKey {
  cardColorBrightEnabled,
  cardColorBrightDisabled,
  cardColorDarkEnabled,
  cardColorDarkDisabled,

  runTogether,

  moveOnDrag,

  iniEditorArg,

  showFolderIcon,

  showEnabledModsFirst,

  darkMode,

  showPaimonAsEmptyIconFolderIcon,

  separateRunSuffix('.overrideRun'),

  windowWidth,
  windowHeight,

  columnStrategyType,
  columnStrategyValue,

  configVersion;

  const StorageAccessKey([this.overrideValue]);
  final String? overrideValue;

  String get name => overrideValue ?? (this as Enum).name;
}
