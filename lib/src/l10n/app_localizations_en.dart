import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String modManager(String game, String updateMarker) {
    String _temp0 = intl.Intl.selectLogic(
      updateMarker,
      {
        'update': ' (update!)',
        'other': '',
      },
    );
    return '$game Mod Manager$_temp0';
  }

  @override
  String get noDescription => 'No description';

  @override
  String get searchTags => 'Search tags';

  @override
  String get displayedLocaleName => 'English';
}
