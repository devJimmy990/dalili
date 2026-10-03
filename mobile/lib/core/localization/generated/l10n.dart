// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Dalili`
  String get appName {
    return Intl.message('Dalili', name: 'appName', desc: '', args: []);
  }

  /// `Search books, articles...`
  String get searchHint {
    return Intl.message(
      'Search books, articles...',
      name: 'searchHint',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Dalili`
  String get welcomeTitle {
    return Intl.message(
      'Welcome to Dalili',
      name: 'welcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your smart library assistant`
  String get welcomeSubtitle {
    return Intl.message(
      'Your smart library assistant',
      name: 'welcomeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Departments`
  String get departments {
    return Intl.message('Departments', name: 'departments', desc: '', args: []);
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `Suggested Books`
  String get suggestedBooks {
    return Intl.message(
      'Suggested Books',
      name: 'suggestedBooks',
      desc: '',
      args: [],
    );
  }

  /// `Scan Book`
  String get scanBook {
    return Intl.message('Scan Book', name: 'scanBook', desc: '', args: []);
  }

  /// `Indoor Navigation`
  String get indoorNav {
    return Intl.message(
      'Indoor Navigation',
      name: 'indoorNav',
      desc: '',
      args: [],
    );
  }

  /// `Search Books`
  String get searchBooks {
    return Intl.message(
      'Search Books',
      name: 'searchBooks',
      desc: '',
      args: [],
    );
  }

  /// `Related Articles`
  String get relatedArticles {
    return Intl.message(
      'Related Articles',
      name: 'relatedArticles',
      desc: '',
      args: [],
    );
  }

  /// `Book not found`
  String get bookNotFound {
    return Intl.message(
      'Book not found',
      name: 'bookNotFound',
      desc: '',
      args: [],
    );
  }

  /// `No articles available`
  String get noArticles {
    return Intl.message(
      'No articles available',
      name: 'noArticles',
      desc: '',
      args: [],
    );
  }

  /// `No favorites yet`
  String get noFavorites {
    return Intl.message(
      'No favorites yet',
      name: 'noFavorites',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get noResults {
    return Intl.message(
      'No results found',
      name: 'noResults',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `An error occurred`
  String get error {
    return Intl.message('An error occurred', name: 'error', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Favorites`
  String get favorites {
    return Intl.message('Favorites', name: 'favorites', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Navigation`
  String get navigation {
    return Intl.message('Navigation', name: 'navigation', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Light`
  String get lightTheme {
    return Intl.message('Light', name: 'lightTheme', desc: '', args: []);
  }

  /// `Dark`
  String get darkTheme {
    return Intl.message('Dark', name: 'darkTheme', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueBtn {
    return Intl.message('Continue', name: 'continueBtn', desc: '', args: []);
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Scan Any Book`
  String get onboardScanTitle {
    return Intl.message(
      'Scan Any Book',
      name: 'onboardScanTitle',
      desc: '',
      args: [],
    );
  }

  /// `Point your camera at a book's barcode to instantly find it in our library catalog.`
  String get onboardScanDesc {
    return Intl.message(
      'Point your camera at a book\'s barcode to instantly find it in our library catalog.',
      name: 'onboardScanDesc',
      desc: '',
      args: [],
    );
  }

  /// `Navigate Indoors`
  String get onboardNavTitle {
    return Intl.message(
      'Navigate Indoors',
      name: 'onboardNavTitle',
      desc: '',
      args: [],
    );
  }

  /// `Get guided directions to any book's exact shelf location inside the library.`
  String get onboardNavDesc {
    return Intl.message(
      'Get guided directions to any book\'s exact shelf location inside the library.',
      name: 'onboardNavDesc',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get getStarted {
    return Intl.message('Get Started', name: 'getStarted', desc: '', args: []);
  }

  /// `Publisher`
  String get publisher {
    return Intl.message('Publisher', name: 'publisher', desc: '', args: []);
  }

  /// `Year`
  String get year {
    return Intl.message('Year', name: 'year', desc: '', args: []);
  }

  /// `Edition`
  String get edition {
    return Intl.message('Edition', name: 'edition', desc: '', args: []);
  }

  /// `Language`
  String get bookLanguage {
    return Intl.message('Language', name: 'bookLanguage', desc: '', args: []);
  }

  /// `Classification`
  String get classification {
    return Intl.message(
      'Classification',
      name: 'classification',
      desc: '',
      args: [],
    );
  }

  /// `Align the barcode within the frame`
  String get scanInstruction {
    return Intl.message(
      'Align the barcode within the frame',
      name: 'scanInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Book recognized!`
  String get bookRecognized {
    return Intl.message(
      'Book recognized!',
      name: 'bookRecognized',
      desc: '',
      args: [],
    );
  }

  /// `Point camera at a book barcode`
  String get pointCameraAtBook {
    return Intl.message(
      'Point camera at a book barcode',
      name: 'pointCameraAtBook',
      desc: '',
      args: [],
    );
  }

  /// `Hold steady for best results`
  String get scanHintBottom {
    return Intl.message(
      'Hold steady for best results',
      name: 'scanHintBottom',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message('Author', name: 'author', desc: '', args: []);
  }

  /// `Department`
  String get department {
    return Intl.message('Department', name: 'department', desc: '', args: []);
  }

  /// `Shelf`
  String get shelf {
    return Intl.message('Shelf', name: 'shelf', desc: '', args: []);
  }

  /// `Added to favorites`
  String get addedToFavorites {
    return Intl.message(
      'Added to favorites',
      name: 'addedToFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Removed from favorites`
  String get removedFromFavorites {
    return Intl.message(
      'Removed from favorites',
      name: 'removedFromFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message('Coming Soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `ISBN`
  String get isbn {
    return Intl.message('ISBN', name: 'isbn', desc: '', args: []);
  }

  /// `Call Number`
  String get callNumber {
    return Intl.message('Call Number', name: 'callNumber', desc: '', args: []);
  }

  /// `Place of Publication`
  String get placeOfPublication {
    return Intl.message(
      'Place of Publication',
      name: 'placeOfPublication',
      desc: '',
      args: [],
    );
  }

  /// `Document Type`
  String get documentType {
    return Intl.message(
      'Document Type',
      name: 'documentType',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get articleSource {
    return Intl.message('Source', name: 'articleSource', desc: '', args: []);
  }

  /// `Volume`
  String get articleVolume {
    return Intl.message('Volume', name: 'articleVolume', desc: '', args: []);
  }

  /// `Issue`
  String get articleIssue {
    return Intl.message('Issue', name: 'articleIssue', desc: '', args: []);
  }

  /// `Pages`
  String get articlePages {
    return Intl.message('Pages', name: 'articlePages', desc: '', args: []);
  }

  /// `ISSN`
  String get articleIssn {
    return Intl.message('ISSN', name: 'articleIssn', desc: '', args: []);
  }

  /// `Location`
  String get shelfLocation {
    return Intl.message('Location', name: 'shelfLocation', desc: '', args: []);
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Scan Again`
  String get scanAgain {
    return Intl.message('Scan Again', name: 'scanAgain', desc: '', args: []);
  }

  /// `This book was not found in the database`
  String get bookNotFoundDesc {
    return Intl.message(
      'This book was not found in the database',
      name: 'bookNotFoundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Select where you want to go`
  String get navSelectDestinationHint {
    return Intl.message(
      'Select where you want to go',
      name: 'navSelectDestinationHint',
      desc: '',
      args: [],
    );
  }

  /// `AR Navigation`
  String get navArNavigationTitle {
    return Intl.message(
      'AR Navigation',
      name: 'navArNavigationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR again`
  String get navScanQrTooltip {
    return Intl.message(
      'Scan QR again',
      name: 'navScanQrTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Again`
  String get navScanQrAgain {
    return Intl.message(
      'Scan QR Again',
      name: 'navScanQrAgain',
      desc: '',
      args: [],
    );
  }

  /// `Cancel navigation?`
  String get navCancelNavigationTitle {
    return Intl.message(
      'Cancel navigation?',
      name: 'navCancelNavigationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Leaving now will cancel your current trip. You'll need to select a destination and scan a QR code again to restart.`
  String get navCancelNavigationBody {
    return Intl.message(
      'Leaving now will cancel your current trip. You\'ll need to select a destination and scan a QR code again to restart.',
      name: 'navCancelNavigationBody',
      desc: '',
      args: [],
    );
  }

  /// `Keep going`
  String get navKeepGoing {
    return Intl.message('Keep going', name: 'navKeepGoing', desc: '', args: []);
  }

  /// `Cancel trip`
  String get navCancelTrip {
    return Intl.message(
      'Cancel trip',
      name: 'navCancelTrip',
      desc: '',
      args: [],
    );
  }

  /// `You've arrived at your destination 🎉`
  String get navArrivedMessage {
    return Intl.message(
      'You\'ve arrived at your destination 🎉',
      name: 'navArrivedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get navDone {
    return Intl.message('Done', name: 'navDone', desc: '', args: []);
  }

  /// `Camera permission is required for AR navigation. Please grant it in system settings.`
  String get navCameraPermissionRequired {
    return Intl.message(
      'Camera permission is required for AR navigation. Please grant it in system settings.',
      name: 'navCameraPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `No camera was found on this device.`
  String get navNoCameraFound {
    return Intl.message(
      'No camera was found on this device.',
      name: 'navNoCameraFound',
      desc: '',
      args: [],
    );
  }

  /// `No destinations found in this map.`
  String get navNoDestinationsFound {
    return Intl.message(
      'No destinations found in this map.',
      name: 'navNoDestinationsFound',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get navRetryLabel {
    return Intl.message('Retry', name: 'navRetryLabel', desc: '', args: []);
  }

  /// `Scan Start QR`
  String get navScanStartQrTitle {
    return Intl.message(
      'Scan Start QR',
      name: 'navScanStartQrTitle',
      desc: '',
      args: [],
    );
  }

  /// `Scan Current QR`
  String get navScanCurrentQrTitle {
    return Intl.message(
      'Scan Current QR',
      name: 'navScanCurrentQrTitle',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't start the camera: {error}`
  String navCameraStartError(Object error) {
    return Intl.message(
      'Couldn\'t start the camera: $error',
      name: 'navCameraStartError',
      desc: '',
      args: [error],
    );
  }

  /// `{distance} m remaining`
  String navRemainingDistance(Object distance) {
    return Intl.message(
      '$distance m remaining',
      name: 'navRemainingDistance',
      desc: '',
      args: [distance],
    );
  }

  /// `Heading: {value}°`
  String navHeadingLabel(Object value) {
    return Intl.message(
      'Heading: $value°',
      name: 'navHeadingLabel',
      desc: '',
      args: [value],
    );
  }

  /// `Target difference: {value}°`
  String navTargetDifferenceLabel(Object value) {
    return Intl.message(
      'Target difference: $value°',
      name: 'navTargetDifferenceLabel',
      desc: '',
      args: [value],
    );
  }

  /// `Unrecognized QR code: {code}`
  String navUnrecognizedQr(Object code) {
    return Intl.message(
      'Unrecognized QR code: $code',
      name: 'navUnrecognizedQr',
      desc: '',
      args: [code],
    );
  }

  /// `Motion & fitness / location permission is required for live navigation. Please grant it in system settings and try again.`
  String get navSensorPermissionError {
    return Intl.message(
      'Motion & fitness / location permission is required for live navigation. Please grant it in system settings and try again.',
      name: 'navSensorPermissionError',
      desc: '',
      args: [],
    );
  }

  /// `Go straight`
  String get navGoStraight {
    return Intl.message(
      'Go straight',
      name: 'navGoStraight',
      desc: '',
      args: [],
    );
  }

  /// `Bear right slightly`
  String get navSlightRight {
    return Intl.message(
      'Bear right slightly',
      name: 'navSlightRight',
      desc: '',
      args: [],
    );
  }

  /// `Bear left slightly`
  String get navSlightLeft {
    return Intl.message(
      'Bear left slightly',
      name: 'navSlightLeft',
      desc: '',
      args: [],
    );
  }

  /// `Turn right`
  String get navTurnRight {
    return Intl.message('Turn right', name: 'navTurnRight', desc: '', args: []);
  }

  /// `Turn left`
  String get navTurnLeft {
    return Intl.message('Turn left', name: 'navTurnLeft', desc: '', args: []);
  }

  /// `Turn around`
  String get navUTurn {
    return Intl.message('Turn around', name: 'navUTurn', desc: '', args: []);
  }

  /// `Start walking for {distance} m`
  String navInstructionStart(Object distance) {
    return Intl.message(
      'Start walking for $distance m',
      name: 'navInstructionStart',
      desc: '',
      args: [distance],
    );
  }

  /// `Continue straight for {distance} m`
  String navInstructionForward(Object distance) {
    return Intl.message(
      'Continue straight for $distance m',
      name: 'navInstructionForward',
      desc: '',
      args: [distance],
    );
  }

  /// `Take me to the book`
  String get navigateToBook {
    return Intl.message(
      'Take me to the book',
      name: 'navigateToBook',
      desc: '',
      args: [],
    );
  }

  /// `This section is not on the library map yet`
  String get navDestinationUnavailable {
    return Intl.message(
      'This section is not on the library map yet',
      name: 'navDestinationUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Scan my current location QR`
  String get navScanMyLocation {
    return Intl.message(
      'Scan my current location QR',
      name: 'navScanMyLocation',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code nearest to you to start`
  String get navScanToStart {
    return Intl.message(
      'Scan the QR code nearest to you to start',
      name: 'navScanToStart',
      desc: '',
      args: [],
    );
  }

  /// `Destination: {name}`
  String navDestinationLabel(Object name) {
    return Intl.message(
      'Destination: $name',
      name: 'navDestinationLabel',
      desc: '',
      args: [name],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
