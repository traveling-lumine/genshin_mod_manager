import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String modManager(String game, String updateMarker) {
    return '$game 모드매니저$updateMarker';
  }

  @override
  String get updateMarker => ' (업데이트!)';

  @override
  String get noDescription => '상세정보 없음';

  @override
  String get searchTags => '태그 검색';
}
