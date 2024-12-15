import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String modManager(String game, String updateMarker) {
    String _temp0 = intl.Intl.selectLogic(
      updateMarker,
      {
        'update': ' (업데이트!)',
        'other': '',
      },
    );
    return '$game 모드 매니저$_temp0';
  }

  @override
  String get noDescription => '상세정보 없음';

  @override
  String get searchTags => '태그 검색';

  @override
  String get displayedLocaleName => '한국어';
}
