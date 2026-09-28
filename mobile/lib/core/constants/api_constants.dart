/// Paths on the Dalili REST API, relative to `API_BASE_URL`.
class ApiConstants {
  ApiConstants._();

  static const String health = '/health';
  static const String books = '/books';
  static const String booksSearch = '/books/search';
  static const String booksByIds = '/books/by-ids';
  static const String departments = '/departments';
  static const String places = '/places';

  static String book(String id) => '/books/$id';
  static String bookArticles(String id) => '/books/$id/articles';
  static String departmentBooks(String id) => '/departments/$id/books';

  // ── Query parameters ──
  static const String paramLang = 'lang';
  static const String paramPage = 'page';
  static const String paramLimit = 'limit';
  static const String paramQuery = 'q';
  static const String paramIds = 'ids';
  static const String paramAuthor = 'author';
  static const String paramDepartment = 'department';
}
