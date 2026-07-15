You are a Senior Flutter Developer. Implement the Dalili (دليلي) Smart Library Assistant App for Android using Flutter 3.41.9 via FVM. Follow every rule and decision below with zero deviation. When in doubt, refer back to this document.

═══════════════════════════════════════════════════════════
SECTION 1: NON-NEGOTIABLE RULES
═══════════════════════════════════════════════════════════

1. Always use `fvm flutter` — never global flutter.
2. Flutter SDK: 3.41.9 via FVM only.
3. Clean Architecture: presentation → domain → data. Strict layer separation.
4. Domain: Pure Dart only — zero external imports.
5. No business logic inside Widgets — UI renders state and calls Cubit methods only.
6. All state classes: single class + status enum + copyWith + Equatable.
7. ALL cubits extend HydratedCubit — never plain Cubit.
8. fromJson: always reset status to initial — never restore loading/error.
9. toJson: only persist data fields — never status or errorMessage.
10. Repositories throw Failure subclasses — no Either, no dartz.
11. Always handle: initial, loading, success/empty, error — never skip any.
12. All strings from AppLocalizations static class — never hardcode text.
13. All colors via Theme.of(context).colorScheme or context.appTheme — never hardcode hex.
14. All text styles via Theme.of(context).textTheme — never hardcode TextStyle inline.
15. No hardcoded API URLs — use flutter_dotenv and .env file.
16. Validate all API data (null-safe, type-safe) before passing to domain.
17. const constructors everywhere possible.
18. No loops or heavy logic inside build().
19. Always package imports: package:dalili/... — never relative imports.
20. AppLogger only — never print().
21. fvm dart format . before every commit.

═══════════════════════════════════════════════════════════
SECTION 2: PACKAGES
═══════════════════════════════════════════════════════════

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  flutter_bloc: ^9.1.1
  hydrated_bloc: ^11.0.0
  equatable: ^2.0.8
  get_it: ^9.2.1
  dio: ^5.8.0+1
  flutter_dotenv: ^5.2.1
  mobile_scanner: ^7.0.0
  cached_network_image: ^3.4.1
  url_launcher: ^6.3.1
  sensors_plus: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  intl_utils: ^2.8.7

flutter:
  generate: true
  assets:
    - .env
    - assets/images/
    - assets/fonts/
  fonts:
    - family: Tajawal
      fonts:
        - asset: assets/fonts/Tajawal-Regular.ttf
        - asset: assets/fonts/Tajawal-Bold.ttf
          weight: 700
    - family: Almarai
      fonts:
        - asset: assets/fonts/Almarai-Regular.ttf
        - asset: assets/fonts/Almarai-Bold.ttf
          weight: 700

Create l10n.yaml at project root:
  arb-dir: lib/l10n
  template-arb-file: intl_en.arb
  output-localization-file: l10n.dart
  output-dir: lib/generated

Do NOT add any package not listed above.

═══════════════════════════════════════════════════════════
SECTION 3: FOLDER STRUCTURE
═══════════════════════════════════════════════════════════

lib/
├── core/
│   ├── constants/
│   │   ├── app_spacing.dart
│   │   └── api_constants.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── localization/
│   │   └── app_localizations.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_theme_extension.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       └── app_logger.dart
│
├── l10n/
│   ├── intl_ar.arb
│   └── intl_en.arb
│
├── generated/
│   └── l10n.dart               ← auto-generated, never edit manually
│
├── features/library/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── library_remote_datasource.dart
│   │   ├── models/
│   │   │   ├── department_model.dart
│   │   │   ├── article_model.dart
│   │   │   └── book_model.dart
│   │   └── repositories/
│   │       └── library_repository_impl.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── department.dart
│   │   │   ├── article.dart
│   │   │   └── book.dart
│   │   ├── repositories/
│   │   │   └── library_repository.dart
│   │   └── usecases/
│   │       ├── get_all_books.dart
│   │       ├── get_book_by_id.dart
│   │       ├── search_books.dart
│   │       ├── get_books_by_department.dart
│   │       └── get_departments.dart
│   │
│   └── presentation/
│       ├── cubits/
│       │   ├── app_settings/
│       │   │   ├── app_settings_cubit.dart
│       │   │   └── app_settings_state.dart
│       │   ├── department/
│       │   │   ├── department_cubit.dart
│       │   │   └── department_state.dart
│       │   ├── search/
│       │   │   ├── search_cubit.dart
│       │   │   └── search_state.dart
│       │   ├── scanner/
│       │   │   ├── scanner_cubit.dart
│       │   │   └── scanner_state.dart
│       │   ├── book_detail/
│       │   │   ├── book_detail_cubit.dart
│       │   │   └── book_detail_state.dart
│       │   └── favorites/
│       │       ├── favorites_cubit.dart
│       │       └── favorites_state.dart
│       │
│       ├── screens/
│       │   ├── onboarding/
│       │   │   ├── onboarding_screen.dart
│       │   │   ├── language_page.dart
│       │   │   ├── onboard_scan_page.dart
│       │   │   └── onboard_navigate_page.dart
│       │   ├── main_layout.dart
│       │   ├── home/
│       │   │   └── home_screen.dart
│       │   ├── search/
│       │   │   └── search_screen.dart
│       │   ├── scanner/
│       │   │   └── scanner_screen.dart
│       │   ├── book_detail/
│       │   │   └── book_detail_screen.dart
│       │   ├── articles/
│       │   │   └── articles_screen.dart
│       │   ├── department/
│       │   │   └── department_books_screen.dart
│       │   ├── favorites/
│       │   │   └── favorites_screen.dart
│       │   ├── settings/
│       │   │   └── settings_screen.dart
│       │   └── navigation/
│       │       └── navigation_screen.dart
│       │
│       └── widgets/
│           ├── book_card.dart
│           ├── article_card.dart
│           ├── department_tile.dart
│           ├── welcome_banner.dart
│           ├── search_bar_widget.dart
│           ├── score_badge.dart
│           ├── cover_image.dart
│           ├── lang_selector_button.dart
│           └── state_widgets/
│               ├── loading_widget.dart
│               ├── error_widget.dart
│               └── empty_widget.dart
│
└── main.dart

Project root:
  .env
  l10n.yaml
  analysis_options.yaml

assets/
  fonts/    ← font files added later
  images/   ← image assets added later

═══════════════════════════════════════════════════════════
SECTION 4: ENVIRONMENT & LOCALIZATION CONFIG
═══════════════════════════════════════════════════════════

.env file:
  APPS_SCRIPT_URL=<https://script.google.com/macros/s/YOUR_ID/exec>

l10n.yaml:
  arb-dir: lib/l10n
  template-arb-file: intl_en.arb
  output-localization-file: l10n.dart
  output-dir: lib/generated

After creating ARB files, run:
  fvm flutter gen-l10n

═══════════════════════════════════════════════════════════
SECTION 5: LOCALIZATION
═══════════════════════════════════════════════════════════

Create lib/l10n/intl_ar.arb:
{
  "@@locale": "ar",
  "appName": "دليلي",
  "searchHint": "ابحث عن كتاب أو موضوع...",
  "welcomeTitle": "مرحباً بك",
  "welcomeSubtitle": "في مكتبة كلية الهندسة الذكية",
  "departments": "الأقسام الرئيسية",
  "viewAll": "عرض الكل",
  "scanBook": "مسح كتاب (AR)",
  "indoorNav": "التوجيه داخل المكتبة",
  "searchBooks": "البحث عن كتاب",
  "relatedArticles": "مقالات وأبحاث مرتبطة",
  "bookNotFound": "لم يتم العثور على الكتاب",
  "noArticles": "لا توجد مقالات مرتبطة",
  "noFavorites": "لا توجد كتب مفضلة",
  "noResults": "لا توجد نتائج",
  "loading": "جاري التحميل...",
  "error": "حدث خطأ",
  "retry": "إعادة المحاولة",
  "favorites": "المفضلة",
  "settings": "الإعدادات",
  "home": "الرئيسية",
  "navigation": "التوجيه",
  "language": "اللغة",
  "theme": "المظهر",
  "lightTheme": "فاتح",
  "darkTheme": "داكن",
  "arabic": "العربية",
  "english": "الإنجليزية",
  "selectLanguage": "اختر اللغة",
  "continueBtn": "متابعة",
  "skip": "تخطي",
  "onboardScanTitle": "امسح الكتاب",
  "onboardScanDesc": "وجه الكاميرا على الباركود للحصول على تفاصيل الكتاب فوراً",
  "onboardNavTitle": "التوجيه الذكي",
  "onboardNavDesc": "دعنا نرشدك إلى أي رف في المكتبة باستخدام الواقع المعزز",
  "getStarted": "ابدأ الآن",
  "publisher": "الناشر",
  "year": "سنة النشر",
  "edition": "الطبعة",
  "bookLanguage": "اللغة",
  "classification": "رقم التصنيف",
  "scanInstruction": "وجه الكاميرا على غلاف الكتاب للتعرف عليه",
  "bookRecognized": "تم التعرف على الكتاب",
  "pointCameraAtBook": "وجه الكاميرا على غلاف الكتاب",
  "scanHintBottom": "اضغط على أيقونة لعرض المقالات والأبحاث المرتبطة",
  "author": "المؤلف",
  "department": "القسم",
  "shelf": "الرف",
  "addedToFavorites": "تمت الإضافة للمفضلة",
  "removedFromFavorites": "تمت الإزالة من المفضلة",
  "comingSoon": "قريباً",
  "isbn": "الرقم الدولي ISBN"
}

Create lib/l10n/intl_en.arb:
{
  "@@locale": "en",
  "appName": "Dalili",
  "searchHint": "Search for a book or topic...",
  "welcomeTitle": "Welcome",
  "welcomeSubtitle": "Smart Engineering Library",
  "departments": "Main Departments",
  "viewAll": "View All",
  "scanBook": "Scan Book (AR)",
  "indoorNav": "Indoor Navigation",
  "searchBooks": "Search Books",
  "relatedArticles": "Related Articles & Research",
  "bookNotFound": "Book not found",
  "noArticles": "No related articles",
  "noFavorites": "No favorite books",
  "noResults": "No results found",
  "loading": "Loading...",
  "error": "An error occurred",
  "retry": "Retry",
  "favorites": "Favorites",
  "settings": "Settings",
  "home": "Home",
  "navigation": "Navigation",
  "language": "Language",
  "theme": "Theme",
  "lightTheme": "Light",
  "darkTheme": "Dark",
  "arabic": "Arabic",
  "english": "English",
  "selectLanguage": "Select Language",
  "continueBtn": "Continue",
  "skip": "Skip",
  "onboardScanTitle": "Scan the Book",
  "onboardScanDesc": "Point your camera at the barcode to instantly get book details",
  "onboardNavTitle": "Smart Navigation",
  "onboardNavDesc": "We guide you to any shelf in the library using Augmented Reality",
  "getStarted": "Get Started",
  "publisher": "Publisher",
  "year": "Year",
  "edition": "Edition",
  "bookLanguage": "Language",
  "classification": "Classification",
  "scanInstruction": "Point camera at book cover to identify it",
  "bookRecognized": "Book Recognized",
  "pointCameraAtBook": "Point camera at book cover",
  "scanHintBottom": "Tap the icon to view related articles and research",
  "author": "Author",
  "department": "Department",
  "shelf": "Shelf",
  "addedToFavorites": "Added to favorites",
  "removedFromFavorites": "Removed from favorites",
  "comingSoon": "Coming Soon",
  "isbn": "ISBN"
}

--- AppLocalizations wrapper class ---
File: lib/core/localization/app_localizations.dart

Rules:

- Private constructor AppLocalizations._()
- Static field: static S _s = S()
- Static method: static void update(S instance) => _s = instance
- Every ARB key exposed as static getter: static String get appName => _s.appName;
- Usage across the app: AppLocalizations.appName (never AppLocalizations.of(context))
- Called in DaliliApp builder: AppLocalizations.update(S.current)
- Called in AppSettingsCubit.setLocale after locale change

═══════════════════════════════════════════════════════════
SECTION 6: THEME
═══════════════════════════════════════════════════════════

--- app_theme_extension.dart ---

class AppThemeExtension extends ThemeExtension<AppThemeExtension>:
  Fields:
    Color surfaceContainerLow     → 0xFFEFF4FF
    Color surfaceContainer        → 0xFFE5EEFF
    Color surfaceContainerHigh    → 0xFFDCE9FF
    Color onSurfaceVariant        → 0xFF44474C
    Color outlineVariant          → 0xFFC4C6CD
    Color secondaryContainer      → 0xFF0070EB
    Color onSecondaryContainer    → 0xFFFEFCFF
    double radiusSm               → 4
    double radiusMd               → 12
    double radiusLg               → 16
    double radiusXl               → 24
    double radiusFull             → 9999

  Implements copyWith, lerp (returns this — no interpolation needed for now)

BuildContext extension (in same file or separate ext file):
  extension AppThemeX on BuildContext {
    AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
    ColorScheme get colors => Theme.of(this).colorScheme;
    TextTheme get texts => Theme.of(this).textTheme;
  }

--- app_theme.dart ---

class AppTheme:
  static ThemeData get light:
    useMaterial3: true
    ColorScheme:
      brightness: light
      primary:              0xFF041627
      onPrimary:            0xFFFFFFFF
      primaryContainer:     0xFF1A2B3C
      onPrimaryContainer:   0xFF8192A7
      secondary:            0xFF0058BC
      onSecondary:          0xFFFFFFFF
      secondaryContainer:   0xFF0070EB
      onSecondaryContainer: 0xFFFEFCFF
      surface:              0xFFF8F9FF
      onSurface:            0xFF0B1C30
      surfaceContainerHighest: 0xFFD3E4FE
      error:                0xFFBA1A1A
      onError:              0xFFFFFFFF
      outline:              0xFF74777D
      outlineVariant:       0xFFC4C6CD

    TextTheme (all styles — do not hardcode these in widgets):
      displayLarge:  Tajawal, 32px, w700, height 1.375  ← headline-xl
      displayMedium: Tajawal, 24px, w700, height 1.333  ← headline-lg
      displaySmall:  Tajawal, 20px, w500, height 1.4    ← headline-md
      bodyLarge:     Almarai, 18px, w400, height 1.556  ← body-lg
      bodyMedium:    Almarai, 16px, w400, height 1.5    ← body-md
      labelLarge:    Almarai, 14px, w700, height 1.429  ← label-md
      bodySmall:     Almarai, 12px, w400, height 1.333  ← caption

    extensions: [AppThemeExtension(...)]

--- app_spacing.dart ---
class AppSpacing (private constructor):
  static const double containerMargin = 20
  static const double gutter          = 16
  static const double stackSm         = 8
  static const double stackMd         = 16
  static const double stackLg         = 24

Usage in widgets:
  Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin))
  SizedBox(height: AppSpacing.stackMd)
  BorderRadius.circular(context.appTheme.radiusXl)

═══════════════════════════════════════════════════════════
SECTION 7: DATA MODELS & SHEETS
═══════════════════════════════════════════════════════════

Google Sheet structure (3 sheets):

Sheet: Departments
  id | name_ar | name_en
  D1 | كهرباء  | Electrical Engineering
  D2 | عمارة   | Architecture
  D3 | هندسة مدنية | Civil Engineering
  D4 | هندسة ميكانيكية | Mechanical Engineering
  D5 | علوم الحاسب | Computer Science

Sheet: Books
  id | call_number | title | author | edition | publisher | place | year |
  subjects | location | shelf | department_id | language | cover | isbn

Sheet: Articles
  id | book_ids | title | authors | year | type | source | source_title |
  issn | keywords | volume | issue | pages | url | doi | score

Key rules:
  book_ids separated by /*-*/
  department_id references Departments.id
  cover may be empty → show placeholder
  isbn may be empty — only display if not empty
  score is a string like "75%"
  language is book metadata — never used for filtering
  Articles embed in books in API response via book_ids join

Domain entities (Pure Dart + Equatable):

Department: id, name
Article: id, bookIds(List<String>), title, authors, year, type, source,
         sourceTitle, issn, keywords, volume, issue, pages, url, doi, score
Book: id, callNumber, title, author, edition, publisher, place, year,
      subjects, location, shelf, department(Department), language, cover,
      isbn, articles(List<Article>)

Models (in data layer):
DepartmentModel extends Department:
  fromJson: safe cast all fields
  toJson: {id, name}

ArticleModel extends Article:
  fromJson:
    book_ids: if List → cast; if String → split('/*-*/'); else []
    all others: safe String cast + trim
  toJson:
    book_ids: join with '/*-*/'

BookModel extends Book:
  fromJson:
    department: DepartmentModel.fromJson(json['department'])
    articles: (json['articles'] as List? ?? []).map(ArticleModel.fromJson).toList()
    all strings: (json['field'] as String? ?? '').trim()
  toJson:
    department: (department as DepartmentModel).toJson()
    articles: articles.map((a) => (a as ArticleModel).toJson()).toList()

═══════════════════════════════════════════════════════════
SECTION 8: APPS SCRIPT ENDPOINTS
═══════════════════════════════════════════════════════════

All requests: GET ?action=...&lang=ar|en&...
lang injected automatically by Dio _LangInterceptor

Endpoints:
  getAllBooks?page=1&lang=ar
    → { books:[...], total:N, page:1, has_more:bool }
    books contain embedded articles[] and department:{id,name}

  searchById?id=11797998&lang=ar
    → { book: {..., department:{id,name}, articles:[...]} } or { book: null }

  search?query=electrical&lang=ar
    → { books:[...] }
    partial match on: book title, author, subjects + article title, keywords
    article match → returns linked books

  getBooksByAuthor?author=Johnson&lang=ar
    → { books:[...] }

  getBooksByDepartment?department=D1&lang=ar
    → { books:[...] }
    department param is department id (e.g. "D1")

  getDepartments?lang=ar
    → { departments:[{id:"D1", name:"كهرباء"}, ...] }

═══════════════════════════════════════════════════════════
SECTION 9: DIO CLIENT
═══════════════════════════════════════════════════════════

File: lib/core/network/dio_client.dart

class DioClient:

- Reads baseUrl from dotenv.env['APPS_SCRIPT_URL']
- Adds _LangInterceptor (injects lang param on every request)
- Adds _ErrorInterceptor (catches DioException → throws NetworkFailure)
- connectTimeout: 15s, receiveTimeout: 15s

class _LangInterceptor extends Interceptor:
  onRequest:
    final lang = sl<AppSettingsCubit>().state.locale.languageCode;
    options.queryParameters['lang'] = lang;
    handler.next(options);

class _ErrorInterceptor extends Interceptor:
  onError:
    AppLogger.error('Network error: ${err.message}');
    handler.reject(err);

All datasource methods throw ServerException on non-success status.
Repository catches ServerException → throws ServerFailure(message).

═══════════════════════════════════════════════════════════
SECTION 10: CUBITS
═══════════════════════════════════════════════════════════

--- AppSettingsCubit (Singleton) ---

State fields:
  Locale locale          → persisted
  bool hasSeenOnboarding → persisted

init logic (constructor body):
  if NOT hasSeenOnboarding:
    detect device locale:
      final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      locale = deviceLang == 'ar' ? const Locale('ar') : const Locale('en');
  else:
    use restored locale from storage

Methods:
  setLocale(Locale locale):
    emit(state.copyWith(locale: locale));
    AppLocalizations.update(S.current);

  markOnboardingComplete():
    emit(state.copyWith(hasSeenOnboarding: true));

fromJson: restore locale (languageCode string → Locale) + hasSeenOnboarding
toJson: { 'locale': state.locale.languageCode, 'hasSeenOnboarding': state.hasSeenOnboarding }

--- DepartmentCubit (Factory) ---

State fields:
  DepartmentStatus status
  List<Department> departments
  List<Book> books
  Department? selected
  String errorMessage

Methods:
  loadDepartments() → calls GetDepartments usecase
  loadBooksByDepartment(Department dept) → calls GetBooksByDepartment usecase

fromJson: restore departments only (books/selected reset to empty/null)
toJson: { 'departments': departments.map(toJson).toList() }

--- SearchCubit (Factory) ---

State fields:
  SearchStatus status
  String query
  List<Book> results
  SearchFilter filter (enum: all, books, articles)
  String errorMessage

Methods:
  search(String query):
    _debounce?.cancel();
    if query empty → emit initial state, return
    emit loading
    _debounce = Timer(500ms, () → call SearchBooks → emit success/empty/error)

  setFilter(SearchFilter f): emit state.copyWith(filter: f)
  clear(): _debounce?.cancel(); emit const SearchState()

  @override close(): _debounce?.cancel(); super.close()

fromJson: restore query + results + filter
toJson: persist same

--- ScannerCubit (Factory) ---

State fields:
  ScannerStatus status (scanning, loading, found, notFound, error)
  Book? book
  String errorMessage

static const String _testId = '11797998'
bool_isProcessing = false (NOT in state — internal guard)

Methods:
  onBarcodeDetected(String? rawValue):
    if _isProcessing return
    _isProcessing = true
    final id = rawValue?.trim().isNotEmpty == true ? rawValue!.trim() : _testId
    emit loading → call GetBookById(id)
    found → emit found(book)
    null → emit notFound
    Failure → emit error
    finally:_isProcessing = false

  reset(): _isProcessing = false; emit const ScannerState()

fromJson: return null (never restore — always scanning on open)
toJson: return null

--- BookDetailCubit (Factory) ---

State fields:
  BookDetailStatus status (initial, loaded)
  Book? book

Methods:
  loadBook(Book book): emit state.copyWith(status: loaded, book: book)
  Articles accessed via state.book!.articles — no separate API call

fromJson: restore book via BookModel.fromJson
toJson: { 'book': (state.book as BookModel?)?.toJson() }

--- FavoritesCubit (Singleton) ---

State fields:
  FavoritesStatus status (initial, success, empty)
  List<Book> favorites

Methods:
  addFavorite(Book book): if not already in list → add → emit success
  removeFavorite(String id): remove → emit empty or success
  isFavorite(String id): bool

fromJson: restore favorites via BookModel.fromJson list
toJson: { 'favorites': favorites.map((b) => (b as BookModel).toJson()).toList() }

═══════════════════════════════════════════════════════════
SECTION 11: SCREENS
═══════════════════════════════════════════════════════════

--- main.dart ---

main():
  WidgetsFlutterBinding.ensureInitialized()
  await dotenv.load(fileName: '.env')
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path))
  await initDependencies()
  runApp(const DaliliApp())

DaliliApp extends StatelessWidget:
  BlocBuilder<AppSettingsCubit, AppSettingsState>(
    bloc: sl<AppSettingsCubit>(),
    builder: (context, settings) {
      AppLocalizations.update(S.current);  ← update on every rebuild
      return MaterialApp(
        title: AppLocalizations.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: settings.locale,
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: [S.delegate, GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Directionality(
            textDirection: settings.locale.languageCode == 'ar'
              ? TextDirection.rtl : TextDirection.ltr,
            child: child!)),
        home: settings.hasSeenOnboarding ? const MainLayout() : const OnboardingScreen(),
      );
    })

--- OnboardingScreen ---

StatefulWidget with PageController (3 pages).
Page indicator dots at bottom (3 dots, active = secondary color).

Page 0: LanguagePage

- Full screen, centered layout
- App logo/name at top
- Title: "اختر اللغة / Select Language" (show both always since lang not chosen yet)
- Two large rounded cards:
    Card 1: "العربية 🇸🇦" → sl<AppSettingsCubit>().setLocale(Locale('ar'))
                            → pageController.nextPage()
    Card 2: "English 🇺🇸"  → sl<AppSettingsCubit>().setLocale(Locale('en'))
                            → pageController.nextPage()
- No skip button on this page
- Selecting language immediately updates remaining pages via BlocBuilder

Page 1: OnboardScanPage

- AppLocalizations.onboardScanTitle (headline)
- AppLocalizations.onboardScanDesc (body)
- Illustration placeholder (Container with icon if image not available)
- "تخطي / Skip" button top-right → markOnboardingComplete() → MainLayout
- "متابعة / Continue" button → pageController.nextPage()

Page 2: OnboardNavigatePage

- AppLocalizations.onboardNavTitle
- AppLocalizations.onboardNavDesc
- Illustration placeholder
- "ابدأ الآن / Get Started" button → markOnboardingComplete() → Navigator.pushReplacement(MainLayout)
- No skip on last page

--- MainLayout ---

StatefulWidget.
Bottom: NavigationBar (Material 3) with 4 destinations:
  Index 0: home icon      → AppLocalizations.home
  Index 1: directions icon → AppLocalizations.navigation
  Index 2: favorite icon  → AppLocalizations.favorites
  Index 3: settings icon  → AppLocalizations.settings

Body: IndexedStack (preserves state across tab switches)
  0 → HomeScreen (wrapped in BlocProvider<DepartmentCubit>)
  1 → NavigationScreen
  2 → FavoritesScreen (uses singleton FavoritesCubit from sl)
  3 → SettingsScreen

NavigationBar styling:
  backgroundColor: Theme.of(context).colorScheme.surface
  indicatorColor: context.colors.secondaryContainer
  Active icon/label: context.colors.secondary
  Inactive: context.colors.onSurfaceVariant

--- HomeScreen ---

No HomeCubit. Driven by DepartmentCubit injected from MainLayout's BlocProvider.

Layout (SingleChildScrollView, RTL):

  1. WelcomeBanner widget (full width, ~180px height)
     - Background image: assets/images/welcome_banner.png (or colored container if missing)
     - Dark gradient overlay
     - Title: AppLocalizations.welcomeTitle (displayMedium, white, bold)
     - Subtitle: AppLocalizations.welcomeSubtitle (bodyMedium, white70)

  2. SizedBox(height: AppSpacing.stackMd)

  3. Padding(horizontal: AppSpacing.containerMargin):
     SearchBarWidget (tappable only):
       - GestureDetector onTap → Navigator.push(SearchScreen)
       - Rounded (radiusFull from appTheme)
       - surfaceContainerLow background
       - Search icon (right, RTL)
       - Hint: AppLocalizations.searchHint (onSurfaceVariant color)

  4. SizedBox(height: AppSpacing.stackLg)

  5. Padding(horizontal: AppSpacing.containerMargin):
     Row: Text(AppLocalizations.departments, displaySmall) + Spacer + TextButton(AppLocalizations.viewAll)

  6. BlocBuilder<DepartmentCubit, DepartmentState> on departments field:
     loading → LoadingWidget
     error   → ErrorWidget(onRetry: cubit.loadDepartments)
     empty   → EmptyWidget
     success → ListView.builder(
       shrinkWrap: true,
       physics: NeverScrollableScrollPhysics(),
       itemCount: state.departments.length,
       itemBuilder: (_, i) => DepartmentTile(
         department: state.departments[i],
         onTap: () => Navigator.push(DepartmentBooksScreen(dept)),
       ))

  7. FloatingActionButton (position via Stack or Scaffold.floatingActionButton):
     Icon: QR code icon
     backgroundColor: context.colors.secondary
     onPressed: Navigator.push(ScannerScreen)

  initState: context.read<DepartmentCubit>().loadDepartments()

--- SearchScreen ---

BlocProvider<SearchCubit>(create: (_) => sl())
Layout:
  AppBar: title AppLocalizations.searchBooks, back arrow
  SearchBarWidget (editable):
    onChanged: cubit.search(value) ← debounce inside cubit
  SizedBox(height: AppSpacing.stackSm)
  Filter chips row (horizontal scroll):
    Chip('الكل / All', SearchFilter.all)
    Chip('كتب / Books', SearchFilter.books)
    Chip('مقالات / Articles', SearchFilter.articles)
    selected chip: secondary color bg, white text
    unselected: surfaceContainerLow bg, onSurface text
    onTap: cubit.setFilter(filter)
  SizedBox(height: AppSpacing.stackMd)
  BlocBuilder<SearchCubit>:
    initial  → empty hint "ابحث عن كتاب..."
    loading  → LoadingWidget
    empty    → EmptyWidget(AppLocalizations.noResults)
    error    → ErrorWidget
    success  → ListView.builder of BookCard
      BookCard tap → Navigator.push(BookDetailScreen(book))
  Bottom: static AR promo banner card

--- ScannerScreen ---

BlocProvider<ScannerCubit>(create: (_) => sl())
Scaffold body: Stack:

  1. MobileScanner (full screen)
     onDetect: cubit.onBarcodeDetected(barcodes.first.rawValue)
  2. CustomPaint: blue bracket corner overlay (4 corners, 12px radius)
  3. BlocBuilder<ScannerCubit>:
     scanning:
       - Bottom panel (dark, rounded top): AppLocalizations.pointCameraAtBook
         - FAB "Test Scan" button → cubit.onBarcodeDetected(null)
     loading:
       - Semi-transparent overlay + CircularProgressIndicator (secondary color)
     found:
       - Semi-transparent card center:
           title (displaySmall, white)
           author (bodyMedium, white70)
           Row: check icon + AppLocalizations.bookRecognized (caption, green)
         GestureDetector → Navigator.pushReplacement(BookDetailScreen(state.book!))
     notFound:
       - Full overlay: icon + AppLocalizations.bookNotFound
         Button "مسح مجدد / Scan Again" → cubit.reset()
     error:
       - SnackBar with state.errorMessage
  4. AppBar (transparent): flash toggle IconButton (top right)
  5. Back button top left → Navigator.pop + cubit.reset()

--- BookDetailScreen ---

Receives Book book as constructor arg.
BlocProvider<BookDetailCubit>(create: (_) => sl()..loadBook(book))

Scaffold:
  extendBodyBehindAppBar: true
  AppBar (transparent, elevation 0):
    leading: back arrow (white)
    actions: BlocBuilder<FavoritesCubit>(
      bloc: sl<FavoritesCubit>(),
      builder: (_, favState) {
        final isFav = sl<FavoritesCubit>().isFavorite(book.id);
        return IconButton(
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: white),
          onPressed: () {
            if (isFav) sl<FavoritesCubit>().removeFavorite(book.id);
            else sl<FavoritesCubit>().addFavorite(book);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(isFav
                ? AppLocalizations.removedFromFavorites
                : AppLocalizations.addedToFavorites)));
          });
      })

  Body: Stack:
    1. Background: full-screen library image (assets/images/welcome_banner.png or colored bg)
       with dark overlay (Colors.black54)
    2. Positioned(bottom: 0, left: 0, right: 0):
       DraggableScrollableSheet or SafeArea column:
         Dark glassmorphism card (surfaceContainerHigh, opacity 0.85, radiusXl top corners,
           backdrop blur 20px via BackdropFilter + ImageFilter.blur):
           Padding(AppSpacing.stackLg):
             Text(book.title, displayMedium, white, textAlign center)
             SizedBox(AppSpacing.stackSm)
             Text(book.author, bodyLarge, white70, textAlign center)
             Divider(color: outlineVariant)
             _InfoRow(AppLocalizations.publisher, book.publisher)
             _InfoRow(AppLocalizations.year, book.year)
             _InfoRow(AppLocalizations.edition, book.edition)
             _InfoRow(AppLocalizations.bookLanguage, book.language)
             _InfoRow(AppLocalizations.classification,
               '${book.location} - ${book.shelf}', icon: Icons.location_on)
             _InfoRow(AppLocalizations.department, book.department.name)
             if (book.isbn.isNotEmpty)
               _InfoRow(AppLocalizations.isbn, book.isbn)
             Divider(color: outlineVariant)
             SizedBox(height: AppSpacing.stackMd)
             ElevatedButton.icon(
               icon: Icon(Icons.link),
               label: Text(AppLocalizations.relatedArticles),
               style: secondary color, full width, radiusLg,
               onPressed: book.articles.isEmpty ? null
                 : () => Navigator.push(ArticlesScreen(book.articles)))
    3. Bottom hint bar (dark panel):
         Text(AppLocalizations.scanHintBottom, caption, white70, center)

_InfoRow: Row with label (labelLarge, onSurfaceVariant) right, value (bodyMedium, white) left (RTL)

--- ArticlesScreen ---

Receives List<Article> articles as constructor arg. No cubit.
AppBar: AppLocalizations.relatedArticles
articles.isEmpty → EmptyWidget(AppLocalizations.noArticles)
ListView.builder:
  ArticleCard:
    title (labelLarge)
    authors (bodySmall, onSurfaceVariant)
    sourceTitle + ' • ' + year (bodySmall)
    if doi not empty: Text('DOI: ' + doi, caption, secondary color)
    Trailing: ScoreBadge(article.score)
    Card surface: surfaceContainerLow, radiusMd border radius
    tap → url_launcher: launchUrl(Uri.parse(article.url))

--- DepartmentBooksScreen ---

Receives Department department as constructor arg.
BlocProvider<DepartmentCubit>(create: (_) => sl()..loadBooksByDepartment(department))
AppBar: department.name, back arrow
BlocBuilder<DepartmentCubit> on books field:
  loading → LoadingWidget
  empty   → EmptyWidget(AppLocalizations.noResults)
  error   → ErrorWidget(onRetry: cubit.loadBooksByDepartment(department))
  success → ListView.builder of BookCard
    tap → Navigator.push(BookDetailScreen(book))

--- FavoritesScreen ---

Uses singleton FavoritesCubit from sl (no new BlocProvider).
BlocBuilder<FavoritesCubit>:
  empty/initial → EmptyWidget(AppLocalizations.noFavorites)
  success → ListView.builder:
    Dismissible(
      key: ValueKey(book.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => sl<FavoritesCubit>().removeFavorite(book.id),
      background: red delete background,
      child: BookCard(
        book: book,
        onTap: () => Navigator.push(BookDetailScreen(book))))

--- SettingsScreen ---

No cubit — reads/writes AppSettingsCubit directly via sl.
Layout (Padding: AppSpacing.containerMargin):
  Text(AppLocalizations.language, displaySmall)
  SizedBox(AppSpacing.stackMd)
  _LangOption(label: AppLocalizations.arabic, locale: Locale('ar'))
  _LangOption(label: AppLocalizations.english, locale: Locale('en'))
  SizedBox(AppSpacing.stackLg)
  Text(AppLocalizations.theme, displaySmall)
  SizedBox(AppSpacing.stackMd)
  _ThemeOption(label: AppLocalizations.lightTheme, enabled: true)
  _ThemeOption(label: AppLocalizations.darkTheme, enabled: false, comingSoon: true)

_LangOption: RadioListTile<Locale>:
  value: locale
  groupValue: sl<AppSettingsCubit>().state.locale
  onChanged: (v) => sl<AppSettingsCubit>().setLocale(v!)
  Wrapped in BlocBuilder<AppSettingsCubit> for reactivity

--- NavigationScreen ---

Placeholder only:
  Center: Column:
    Icon(Icons.navigation, size 64, color: secondary)
    SizedBox(AppSpacing.stackMd)
    Text(AppLocalizations.comingSoon, displaySmall)

═══════════════════════════════════════════════════════════
SECTION 12: SHARED WIDGETS
═══════════════════════════════════════════════════════════

--- BookCard ---
Params: Book book, VoidCallback onTap
Card (surfaceContainerLow bg, radiusMd, subtle shadow):
  Row (RTL → image on right):
    CoverImage(url: book.cover, width: 80, height: 110, radius: radiusMd)
    SizedBox(AppSpacing.gutter)
    Expanded:
      Text(book.title, labelLarge, maxLines: 2, overflow ellipsis)
      Text(book.author, bodySmall, onSurfaceVariant)
      Text(book.publisher + ' • ' + book.year, bodySmall, onSurfaceVariant)
      Row: Icon(location_on, size 14) + Text(book.location+'-'+book.shelf, caption, secondary)

--- ArticleCard ---
Params: Article article, VoidCallback onTap
Card with padding:
  title (labelLarge)
  authors (bodySmall, onSurfaceVariant)
  source info row
  doi (caption, secondary) if not empty
  ScoreBadge trailing

--- DepartmentTile ---
Params: Department department, VoidCallback onTap
ListTile:
  leading: CircleAvatar(bg: secondaryContainer, child: dept icon)
  title: Text(department.name, bodyMedium)
  trailing: Icon(chevron, color: onSurfaceVariant) [RTL: chevron_left]
  onTap: onTap callback
  tileColor: surfaceContainerLow
  shape: RoundedRectangleBorder(radius: radiusMd)

--- CoverImage ---
Params: String url, double width, double height, double radius
CachedNetworkImage with placeholder and errorWidget both → CoverPlaceholder
CoverPlaceholder: Container(color: surfaceContainerHigh, child: Icon(menu_book, color: onSurfaceVariant))

--- ScoreBadge ---
Params: String score
if score.isEmpty → SizedBox.shrink()
Container(padding: H8/V4, decoration: secondary color, radiusFull, child: Text(score, caption, white))

--- SearchBarWidget ---
Params: bool editable, String? initialValue, ValueChanged<String>? onChanged, VoidCallback? onTap
if editable: TextField with onChanged
if not editable: GestureDetector + AbsorbPointer
Style: surfaceContainerLow fill, radiusFull, no border
Leading icon: Icons.search (right in RTL)
Hint: AppLocalizations.searchHint

--- WelcomeBanner ---
Container(height: 180):
  Stack:
    Image.asset('assets/images/welcome_banner.png', fit: cover)
    (or Container(color: primary) as fallback)
    Gradient overlay (black transparent → black54)
    Positioned(bottom, padding):
      Text(AppLocalizations.welcomeTitle, displayMedium, white, bold)
      Text(AppLocalizations.welcomeSubtitle, bodyMedium, white70)

--- LoadingWidget ---
Center → CircularProgressIndicator(color: context.colors.secondary)

--- ErrorWidget (custom) ---
Center → Column:
  Icon(error_outline, size 48, color: error)
  SizedBox(AppSpacing.stackSm)
  Text(AppLocalizations.error, bodyMedium, onSurfaceVariant)
  if onRetry != null:
    TextButton(AppLocalizations.retry, onPressed: onRetry)

--- EmptyWidget ---
Params: String? message
Center → Column:
  Icon(inbox, size 48, color: onSurfaceVariant)
  SizedBox(AppSpacing.stackSm)
  Text(message ?? AppLocalizations.noResults, bodyMedium, onSurfaceVariant)

═══════════════════════════════════════════════════════════
SECTION 13: DEPENDENCY INJECTION
═══════════════════════════════════════════════════════════

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // AppSettingsCubit FIRST (DioClient depends on it)
  sl.registerLazySingleton<AppSettingsCubit>(() => AppSettingsCubit());

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Data sources
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(sl()));

  // Repositories
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAllBooks(sl()));
  sl.registerLazySingleton(() => GetBookById(sl()));
  sl.registerLazySingleton(() => SearchBooks(sl()));
  sl.registerLazySingleton(() => GetBooksByDepartment(sl()));
  sl.registerLazySingleton(() => GetDepartments(sl()));

  // Singleton cubits
  sl.registerLazySingleton<FavoritesCubit>(() => FavoritesCubit());

  // Factory cubits (new instance per screen push)
  sl.registerFactory(() => DepartmentCubit(
    getDepartmentsUseCase: sl(), getBooksByDepartmentUseCase: sl()));
  sl.registerFactory(() => SearchCubit(searchBooksUseCase: sl()));
  sl.registerFactory(() => ScannerCubit(getBookByIdUseCase: sl()));
  sl.registerFactory(() => BookDetailCubit());
}

═══════════════════════════════════════════════════════════
SECTION 14: ANDROID MANIFEST
═══════════════════════════════════════════════════════════

Inside <manifest>:
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-feature android:name="android.hardware.camera" android:required="false"/>

Inside <application>:
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW"/>
      <data android:scheme="https"/>
    </intent>
  </queries>

═══════════════════════════════════════════════════════════
SECTION 15: IMPLEMENTATION ORDER
═══════════════════════════════════════════════════════════

Implement EXACTLY in this order:

1. pubspec.yaml — packages + fonts + assets + generate:true
2. l10n.yaml — arb config
3. lib/l10n/intl_ar.arb + intl_en.arb
4. fvm flutter gen-l10n → generates lib/generated/l10n.dart
5. analysis_options.yaml
6. core/theme/app_theme_extension.dart → app_theme.dart
7. core/constants/app_spacing.dart + api_constants.dart
8. core/localization/app_localizations.dart
9. core/errors/failures.dart + exceptions.dart
10. core/utils/app_logger.dart
11. core/usecase/usecase.dart
12. domain/entities/department.dart → article.dart → book.dart
13. domain/repositories/library_repository.dart
14. domain/usecases/ — all 5
15. data/models/department_model.dart → article_model.dart → book_model.dart
16. data/datasources/library_remote_datasource.dart
17. data/repositories/library_repository_impl.dart
18. core/network/dio_client.dart
19. cubits/app_settings → favorites → department → search → scanner → book_detail
20. core/di/injection_container.dart
21. main.dart
22. widgets/ — all shared widgets
23. screens/onboarding/ → main_layout → home → search → scanner
    → book_detail → articles → department → favorites → settings → navigation

═══════════════════════════════════════════════════════════
SECTION 16: GOOGLE SHEET SETUP CHECKLIST
═══════════════════════════════════════════════════════════

1. Create Google Sheet with 3 tabs: Departments, Books, Articles
2. Departments headers (Row 1): id | name_ar | name_en
3. Books headers (Row 1): id | call_number | title | author | edition |
   publisher | place | year | subjects | location | shelf | department_id |
   language | cover
4. Articles headers (Row 1): id | book_ids | title | authors | year | type |
   source | source_title | issn | keywords | volume | issue | pages | url |
   doi | score
5. Deploy Apps Script as Web App: Execute as Me, Access: Anyone
6. Copy URL → .env as APPS_SCRIPT_URL
7. Test:
   ?action=getDepartments&lang=ar  → [{id,name}]
   ?action=getAllBooks&page=1&lang=ar → {books, total, has_more}
   ?action=searchById&id=11797998&lang=ar → {book with articles}
8. Add .env to .gitignore
