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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Dalili`
  String get appName {
    return Intl.message(
      'Dalili',
      name: 'appName',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Departments',
      name: 'departments',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get viewAll {
    return Intl.message(
      'View All',
      name: 'viewAll',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Scan Book',
      name: 'scanBook',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get error {
    return Intl.message(
      'An error occurred',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message(
      'Favorites',
      name: 'favorites',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Navigation`
  String get navigation {
    return Intl.message(
      'Navigation',
      name: 'navigation',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get lightTheme {
    return Intl.message(
      'Light',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get darkTheme {
    return Intl.message(
      'Dark',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Continue',
      name: 'continueBtn',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Get Started',
      name: 'getStarted',
      desc: '',
      args: [],
    );
  }

  /// `Publisher`
  String get publisher {
    return Intl.message(
      'Publisher',
      name: 'publisher',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Edition`
  String get edition {
    return Intl.message(
      'Edition',
      name: 'edition',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get bookLanguage {
    return Intl.message(
      'Language',
      name: 'bookLanguage',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message(
      'Department',
      name: 'department',
      desc: '',
      args: [],
    );
  }

  /// `Shelf`
  String get shelf {
    return Intl.message(
      'Shelf',
      name: 'shelf',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Coming Soon',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `ISBN`
  String get isbn {
    return Intl.message(
      'ISBN',
      name: 'isbn',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Scan Again',
      name: 'scanAgain',
      desc: '',
      args: [],
    );
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
