/**
 * Dalili API - Google Apps Script
 * قمت بتطوير هذا السكريبت ليعمل كـ Backend لتطبيق Flutter.
 * تأكد من عمل Deploy كـ Web App ومنح الصلاحية لـ Anyone.
 */

// ── الإعدادات (CONFIG) ───────────────────────────────────────
const SHEET_ID     = '1QE1J02EMr9JWc7J-osFEwD8R0eVzUEsrlWSSrvMjGCw';
const BOOKS_SHEET         = 'Books';
const ARTICLES_SHEET      = 'Articles';
const PLACES_SHEET        = 'Places';
const DEPARTMENTS_SHEET   = 'Departments';
const PAGE_SIZE           = 20;
const SEPARATOR           = '/*-*/';
// ───────────────────────────────────────────────────────────
// LOCALIZATION
//
// lang param: 'ar' (default) or 'en'
//
// What is localized:
//   1. Error/response messages     → MESSAGES object
//   2. department.name in response → Departments sheet (name_ar / name_en)
//   3. place in response           → Places sheet (place_ar / place_en) — plain string
//
// What is NOT localized:
//   - Book data fields (title, author, etc.) — returned as-is from sheet
//   - language column — book metadata only, never filtered
//   - Article fields  — returned as-is
//
// department in every book response shape:
//   { id: "D1", name: "كهرباء" }   (lang=ar)
//   { id: "D1", name: "Electrical Engineering" }  (lang=en)
// ───────────────────────────────────────────────────────────

const MESSAGES = {
  ar: {
    missing_action:     'معامل الإجراء مفقود',
    missing_id:         'معامل المعرف مفقود',
    missing_query:      'معامل البحث مفقود',
    missing_author:     'معامل المؤلف مفقود',
    missing_department: 'معامل القسم مفقود',
    missing_ids:        'معامل المعرفات مفقود',
    book_not_found:     'لم يتم العثور على الكتاب',
    unknown_action:     'إجراء غير معروف',
    server_error:       'خطأ في الخادم',
  },
  en: {
    missing_action:     'Missing action parameter',
    missing_id:         'Missing id parameter',
    missing_query:      'Missing query parameter',
    missing_author:     'Missing author parameter',
    missing_department: 'Missing department parameter',
    missing_ids:        'Missing ids parameter',
    book_not_found:     'Book not found',
    unknown_action:     'Unknown action',
    server_error:       'Server error',
  },
};

// ───────────────────────────────────────────────────────────
// ORDINAL MAPPERS
// Shared key: raw number string '1'..'10' (strips any suffix like st/nd/rd/th)
//
// Edition  → English: 1st..10th  | Arabic: الأولى..العاشرة
// Shelf    → English: 1st..10th  | Arabic: الأول..السادس (extended to 10)
// ───────────────────────────────────────────────────────────

const ORDINAL_EN = {
  '1': '1st', '2': '2nd',  '3': '3rd',  '4': '4th',  '5': '5th',
  '6': '6th', '7': '7th',  '8': '8th',  '9': '9th',  '10': '10th',
};

const EDITION_AR = {
  '1': 'الأولى',   '2': 'الثانية',  '3': 'الثالثة',
  '4': 'الرابعة',  '5': 'الخامسة',  '6': 'السادسة',
  '7': 'السابعة',  '8': 'الثامنة',  '9': 'التاسعة',
  '10': 'العاشرة',
};

const SHELF_AR = {
  '1': 'الأول',   '2': 'الثاني',  '3': 'الثالث',
  '4': 'الرابع',  '5': 'الخامس',  '6': 'السادس',
  '7': 'السابع',  '8': 'الثامن',  '9': 'التاسع',
  '10': 'العاشر',
};

// Strips any trailing suffix (st/nd/rd/th/د.ط etc.) and returns the numeric key.
function toOrdinalKey(raw) {
  return String(raw).trim().replace(/[^0-9]/g, '') || raw;
}

function resolveEdition(raw, lang) {
  if (!raw) return '';
  const key = toOrdinalKey(raw);
  if (lang === 'ar') return EDITION_AR[key] || raw;
  return ORDINAL_EN[key] || raw;
}

function resolveShelf(raw, lang) {
  if (!raw) return '';
  const key = toOrdinalKey(raw);
  if (lang === 'ar') return SHELF_AR[key] || raw;
  return ORDINAL_EN[key] || raw;
}

function getLang(e) {
  const lang = (e && e.parameter && e.parameter.lang) || 'ar';
  return MESSAGES[lang] ? lang : 'ar';
}

function msg(lang, key) {
  return (MESSAGES[lang] && MESSAGES[lang][key]) || MESSAGES['ar'][key] || key;
}

// ───────────────────────────────────────────────────────────
// ENTRY POINT
// ───────────────────────────────────────────────────────────

function doGet(e) {
  try {
    const lang   = getLang(e);
    const action = e.parameter.action;

    if (!action) return buildError(msg(lang, 'missing_action'));

    console.log('Action: ' + action + ' | Lang: ' + lang);

    switch (action) {

      case 'getAllBooks': {
        const page = parseInt(e.parameter.page) || 1;
        return getAllBooks(page, lang);
      }

      case 'searchById': {
        const id = e.parameter.id;
        if (!id) return buildError(msg(lang, 'missing_id'));
        return searchById(id, lang);
      }

      case 'search': {
        const query = e.parameter.query;
        if (!query) return buildError(msg(lang, 'missing_query'));
        return search(query, lang);
      }

      case 'getBooksByAuthor': {
        const author = e.parameter.author;
        if (!author) return buildError(msg(lang, 'missing_author'));
        return getBooksByAuthor(author, lang);
      }

      case 'getBooksByDepartment': {
        const department = e.parameter.department;
        if (!department) return buildError(msg(lang, 'missing_department'));
        return getBooksByDepartment(department, lang);
      }

      case 'getDepartments': {
        return getDepartments(lang);
      }

      case 'getBooksByIds': {
        const ids = e.parameter.ids;
        if (!ids) return buildError(msg(lang, 'missing_ids'));
        return getBooksByIds(ids, lang);
      }

      default:
        return buildError(msg(lang, 'unknown_action') + ': ' + action);
    }

  } catch (err) {
    console.error('doGet error: ' + err.stack);
    return buildError(msg(getLang(e), 'server_error') + ': ' + err.message);
  }
}

// ───────────────────────────────────────────────────────────
// DIAGNOSTIC — run manually from Apps Script editor
// ───────────────────────────────────────────────────────────

function runDiagnosticTest() {
  console.log('Starting diagnostic...');
  try {
    SpreadsheetApp.openById(SHEET_ID);
    console.log('Spreadsheet found.');

    // Test departments
    const arDepts = JSON.parse(getDepartments('ar').getContent());
    console.log('getDepartments ar: ' + JSON.stringify(arDepts.data.departments));

    const enDepts = JSON.parse(getDepartments('en').getContent());
    console.log('getDepartments en: ' + JSON.stringify(enDepts.data.departments));

    // Test getAllBooks
    const books = JSON.parse(getAllBooks(1, 'ar').getContent());
    console.log('getAllBooks — count: ' + books.data.books.length + ' | has_more: ' + books.data.has_more);
    if (books.data.books.length > 0) {
      console.log('Sample book: ' + JSON.stringify(books.data.books[0]));
    }

    // Test places
    const places = JSON.parse(getDepartments('ar').getContent());
    console.log('buildPlaceMap ar sample: ' + JSON.stringify(buildPlaceMap('ar')));
    console.log('buildPlaceMap en sample: ' + JSON.stringify(buildPlaceMap('en')));

    // Test getBooksByIds
    const byIds = JSON.parse(getBooksByIds('11797998,12492294', 'ar').getContent());
    console.log('getBooksByIds — count: ' + byIds.data.books.length);
    if (byIds.data.books.length > 0) {
      console.log('Sample (ar): edition=' + byIds.data.books[0].edition + ' shelf=' + byIds.data.books[0].shelf);
    }
    const byIdsEn = JSON.parse(getBooksByIds('11797998,12492294', 'en').getContent());
    console.log('getBooksByIds en: edition=' + byIdsEn.data.books[0].edition + ' shelf=' + byIdsEn.data.books[0].shelf);

    // Test getBooksByDepartment with id
    const byDept = JSON.parse(getBooksByDepartment('D1', 'ar').getContent());
    console.log('getBooksByDepartment D1 — count: ' + byDept.data.books.length);

  } catch (e) {
    console.error('Diagnostic error: ' + e.message);
  }
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: getAllBooks
// Paginated, page size = 20.
// Returns books with embedded articles and joined department object.
// ───────────────────────────────────────────────────────────

function getAllBooks(page, lang) {
  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);

  const dataRows = booksData.rows.slice(1).filter(r => safeStr(r[0]) !== '');
  const total    = dataRows.length;
  const start    = (page - 1) * PAGE_SIZE;
  const pageRows = dataRows.slice(start, start + PAGE_SIZE);
  const hasMore  = (start + PAGE_SIZE) < total;

  const books = pageRows.map(row => {
    const book = buildBookObject(booksData.headers, row, deptMap, placeMap, lang);
    book.articles = getArticlesForBook(book.id, articlesData);
    return book;
  });

  return buildSuccess({ books: books, total: total, page: page, has_more: hasMore });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: searchById
// Exact match on id column.
// Returns single book with embedded articles and department object, or null.
// ───────────────────────────────────────────────────────────

function searchById(id, lang) {
  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);
  const idIdx        = booksData.headers.indexOf('id');

  const row = booksData.rows.slice(1).find(
    r => safeStr(r[idIdx]) === safeStr(id)
  );

  if (!row) return buildSuccess({ book: null });

  const book = buildBookObject(booksData.headers, row, deptMap, placeMap, lang);
  book.articles = getArticlesForBook(book.id, articlesData);

  return buildSuccess({ book: book });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: search
// Partial match on:
//   Books    → title, author, subjects
//   Articles → title, keywords
// Article matches → linked books fetched via book_ids.
// Returns deduplicated books with embedded articles.
// ───────────────────────────────────────────────────────────

function search(query, lang) {
  const lq           = query.toLowerCase().trim();
  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);

  const bookCols    = ['title', 'author', 'subjects'];
  const articleCols = ['title', 'keywords'];

  const bookIdx    = bookCols.map(c => booksData.headers.indexOf(c)).filter(i => i >= 0);
  const artIdx     = articleCols.map(c => articlesData.headers.indexOf(c)).filter(i => i >= 0);
  const bookIdsIdx = articlesData.headers.indexOf('book_ids');

  const matchedIds = new Set();

  // Direct book matches
  booksData.rows.slice(1).forEach(row => {
    if (!safeStr(row[0])) return;
    if (bookIdx.some(i => safeStr(row[i]).toLowerCase().includes(lq))) {
      matchedIds.add(safeStr(row[0]));
    }
  });

  // Article matches → add their linked book ids
  articlesData.rows.slice(1).forEach(row => {
    if (!safeStr(row[0])) return;
    if (artIdx.some(i => safeStr(row[i]).toLowerCase().includes(lq))) {
      splitIds(safeStr(row[bookIdsIdx])).forEach(bid => matchedIds.add(bid));
    }
  });

  const books = booksData.rows.slice(1)
    .filter(row => safeStr(row[0]) && matchedIds.has(safeStr(row[0])))
    .map(row => {
      const book = buildBookObject(booksData.headers, row, deptMap, placeMap, lang);
      book.articles = getArticlesForBook(book.id, articlesData);
      return book;
    });

  return buildSuccess({ books: books });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: getBooksByAuthor
// Partial case-insensitive match on author column.
// ───────────────────────────────────────────────────────────

function getBooksByAuthor(author, lang) {
  const lq           = author.toLowerCase().trim();
  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);
  const authorIdx    = booksData.headers.indexOf('author');

  const books = booksData.rows.slice(1)
    .filter(row => safeStr(row[0]) && safeStr(row[authorIdx]).toLowerCase().includes(lq))
    .map(row => {
      const book = buildBookObject(booksData.headers, row, deptMap, placeMap, lang);
      book.articles = getArticlesForBook(book.id, articlesData);
      return book;
    });

  return buildSuccess({ books: books });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: getBooksByDepartment
// Receives department_id (e.g. "D1").
// Matches on department_id column in Books sheet.
// Returns books with embedded articles and department object.
// ───────────────────────────────────────────────────────────

function getBooksByDepartment(departmentId, lang) {
  const val          = departmentId.trim();
  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);
  const deptIdIdx    = booksData.headers.indexOf('department_id');

  const books = booksData.rows.slice(1)
    .filter(row => safeStr(row[0]) && safeStr(row[deptIdIdx]) === val)
    .map(row => {
      const book = buildBookObject(booksData.headers, row, deptMap, placeMap, lang);
      book.articles = getArticlesForBook(book.id, articlesData);
      return book;
    });

  return buildSuccess({ books: books });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: getDepartments
// Returns all departments as { id, name } based on lang.
// ───────────────────────────────────────────────────────────

function getDepartments(lang) {
  const data    = getDepartmentsData();
  const idIdx   = data.headers.indexOf('id');
  const nameCol = lang === 'en' ? 'name_en' : 'name_ar';
  const nameIdx = data.headers.indexOf(nameCol);

  const departments = data.rows.slice(1)
    .filter(row => safeStr(row[idIdx]) !== '')
    .map(row => ({
      id:   safeStr(row[idIdx]),
      name: safeStr(row[nameIdx]),
    }));

  return buildSuccess({ departments: departments });
}

// ───────────────────────────────────────────────────────────
// ENDPOINT: getBooksByIds
// Accepts comma-separated list of book ids.
// Returns full book objects with embedded articles, department,
// place, edition and shelf resolved — same shape as all other endpoints.
// Used by FavoritesCubit to refresh cached favorites after lang switch.
// ───────────────────────────────────────────────────────────

function getBooksByIds(idsParam, lang) {
  const idList       = idsParam.split(',').map(s => s.trim()).filter(s => s.length > 0);
  if (idList.length === 0) return buildSuccess({ books: [] });

  const booksData    = getBooksData();
  const articlesData = getArticlesData();
  const deptMap      = buildDepartmentMap(lang);
  const placeMap     = buildPlaceMap(lang);
  const idIdx        = booksData.headers.indexOf('id');

  // Preserve order of requested ids
  const rowMap = {};
  booksData.rows.slice(1).forEach(row => {
    const id = safeStr(row[idIdx]);
    if (id) rowMap[id] = row;
  });

  const books = idList
    .filter(id => rowMap[id])
    .map(id => {
      const book = buildBookObject(booksData.headers, rowMap[id], deptMap, placeMap, lang);
      book.articles = getArticlesForBook(book.id, articlesData);
      return book;
    });

  return buildSuccess({ books: books });
}

// ───────────────────────────────────────────────────────────
// DATA LOADERS
// ───────────────────────────────────────────────────────────

function getBooksData() {
  const rows = getSheet(BOOKS_SHEET).getDataRange().getValues();
  return { headers: rows[0].map(h => safeStr(h).toLowerCase()), rows: rows };
}

function getArticlesData() {
  const rows = getSheet(ARTICLES_SHEET).getDataRange().getValues();
  return { headers: rows[0].map(h => safeStr(h).toLowerCase()), rows: rows };
}

function getDepartmentsData() {
  const rows = getSheet(DEPARTMENTS_SHEET).getDataRange().getValues();
  return { headers: rows[0].map(h => safeStr(h).toLowerCase()), rows: rows };
}

function getPlacesData() {
  const rows = getSheet(PLACES_SHEET).getDataRange().getValues();
  return { headers: rows[0].map(h => safeStr(h).toLowerCase()), rows: rows };
}

// ───────────────────────────────────────────────────────────
// BUILD PLACE MAP
// Reads Places sheet once per request and returns a lookup:
//   { "P1": "Scranton" }  (lang=en)
//   { "P1": "سكرانتون" }  (lang=ar)
// Used by buildBookObject to resolve place_id → plain name string.
// ───────────────────────────────────────────────────────────

function buildPlaceMap(lang) {
  const data    = getPlacesData();
  const idIdx   = data.headers.indexOf('id');
  const nameCol = lang === 'en' ? 'place_en' : 'place_ar';
  const nameIdx = data.headers.indexOf(nameCol);

  const map = {};
  data.rows.slice(1).forEach(row => {
    const id = safeStr(row[idIdx]);
    if (id) map[id] = safeStr(row[nameIdx]);
  });
  return map;
}

// ───────────────────────────────────────────────────────────
// BUILD DEPARTMENT MAP
// Reads Departments sheet once per request and returns a lookup:
//   { "D1": { id: "D1", name: "كهرباء" }, ... }
// Used by buildBookObject to join department without re-reading sheet.
// ───────────────────────────────────────────────────────────

function buildDepartmentMap(lang) {
  const data    = getDepartmentsData();
  const idIdx   = data.headers.indexOf('id');
  const nameCol = lang === 'en' ? 'name_en' : 'name_ar';
  const nameIdx = data.headers.indexOf(nameCol);

  const map = {};
  data.rows.slice(1).forEach(row => {
    const id = safeStr(row[idIdx]);
    if (id) {
      map[id] = { id: id, name: safeStr(row[nameIdx]) };
    }
  });
  return map;
}

// ───────────────────────────────────────────────────────────
// OBJECT BUILDERS
// ───────────────────────────────────────────────────────────

// Build a book response object from a sheet row.
// Joins department from deptMap using department_id.
// department in response: { id: "D1", name: "كهرباء" }
function buildBookObject(headers, row, deptMap, placeMap, lang) {
  const get      = field => { const i = headers.indexOf(field); return i >= 0 ? safeStr(row[i]) : ''; };
  const deptId   = get('department_id');
  const deptObj  = deptMap[deptId] || { id: deptId, name: '' };
  const placeId  = get('place_id');
  const placeName = placeMap[placeId] || placeId;

  return {
    id:          get('id'),
    call_number: get('call_number'),
    title:       get('title'),
    author:      get('author'),
    edition:     resolveEdition(get('edition'), lang),
    publisher:   get('publisher'),
    place:       placeName,
    year:        get('year'),
    subjects:    get('subjects'),
    location:    get('location'),
    shelf:       resolveShelf(get('shelf'), lang),
    department:  deptObj,
    language:    get('language'),
    cover:       get('cover'),
    isbn:        get('isbn'),
  };
}

function buildArticleObject(headers, row) {
  const get = field => { const i = headers.indexOf(field); return i >= 0 ? safeStr(row[i]) : ''; };

  return {
    id:           get('id'),
    book_ids:     splitIds(get('book_ids')),
    title:        get('title'),
    authors:      get('authors'),
    year:         get('year'),
    type:         get('type'),
    source:       get('source'),
    source_title: get('source_title'),
    issn:         get('issn'),
    keywords:     get('keywords'),
    volume:       get('volume'),
    issue:        get('issue'),
    pages:        get('pages'),
    url:          get('url'),
    doi:          get('doi'),
    score:        get('score'),
  };
}

// ───────────────────────────────────────────────────────────
// HELPERS
// ───────────────────────────────────────────────────────────

function getArticlesForBook(bookId, articlesData) {
  const bookIdsIdx = articlesData.headers.indexOf('book_ids');
  return articlesData.rows.slice(1)
    .filter(row => safeStr(row[0]) && splitIds(safeStr(row[bookIdsIdx])).includes(safeStr(bookId)))
    .map(row => buildArticleObject(articlesData.headers, row));
}

function splitIds(raw) {
  return raw.split(SEPARATOR).map(s => s.trim()).filter(s => s.length > 0);
}

function getSheet(name) {
  const sheet = SpreadsheetApp.openById(SHEET_ID).getSheetByName(name);
  if (!sheet) throw new Error('Sheet "' + name + '" not found.');
  return sheet;
}

function safeStr(val) {
  return (val === null || val === undefined) ? '' : String(val).trim();
}

function buildSuccess(data) {
  return ContentService
    .createTextOutput(JSON.stringify({ status: 'success', data: data }))
    .setMimeType(ContentService.MimeType.JSON);
}

function buildError(message) {
  return ContentService
    .createTextOutput(JSON.stringify({ status: 'error', message: message }))
    .setMimeType(ContentService.MimeType.JSON);
}