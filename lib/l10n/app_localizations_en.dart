import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String modManager(String game, String updateMarker) {
    return '$game Mod Manager$updateMarker';
  }

  @override
  String get updateMarker => ' (update!)';

  @override
  String get noDescription => 'No description';

  @override
  String get searchTags => 'Search tags';
}
