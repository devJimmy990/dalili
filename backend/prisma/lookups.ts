/**
 * Lookup tables seeded alongside the data, and the rules that map the
 * spreadsheet's free-text cells onto them.
 *
 * Every table row has a stable string id; books and articles store the id,
 * the API resolves the Arabic or English name at response time.
 */

export interface Named {
  id: string;
  nameAr: string;
  nameEn: string;
}

export interface Ordered extends Named {
  sortOrder: number;
}

// ─── Departments ───────────────────────────────────────────

/// The sheet's "المجموعة المنتمي إليها" → department id (see reference-data.ts).
/// The sheet uses short names ("مدني"); the department table has the full ones.
export const DEPARTMENT_BY_SHEET_NAME: Record<string, string> = {
  كهرباء: 'd_electrical',
  عمارة: 'd_architecture',
  مدني: 'd_civil',
  ميكانيكا: 'd_mechanical',
  'علوم أساسية': 'd_basic_sciences',
};

// ─── Places ────────────────────────────────────────────────

/// Normalized "مكان النشر" → place id. The sheet is hand-typed
/// ("Nwe Delhi", "New delhi :", "Boston, Mau."), so keys are matched after
/// `normalizeKey` and every spelling seen is listed explicitly — a new,
/// unlisted spelling aborts the seed instead of creating a stray city.
export const PLACE_BY_SHEET_NAME: Record<string, string> = {
  'new york': 'new-york',
  القاهرة: 'cairo',
  'new delhi': 'new-delhi',
  'nwe delhi': 'new-delhi',
  london: 'london',
  korea: 'korea',
  seoul: 'seoul',
  hardcover: 'hardcover',
  paperback: 'paperback',
  'upper saddle river nj': 'upper-saddle-river',
  'upper saddle river n j': 'upper-saddle-river',
  'washington dc': 'washington',
  'washington d c': 'washington',
  boston: 'boston',
  'boston mau': 'boston',
  cambridge: 'cambridge',
  'sterling va': 'sterling',
  oxford: 'oxford',
  'houndmills basingstoke': 'houndmills-basingstoke',
  basingstoke: 'basingstoke',
  الاسكندرية: 'alexandria',
  'reading mass': 'reading-massachusetts',
  usa: 'usa',
  iran: 'iran',
};

/// Lowercase, strip brackets/punctuation/"+" and collapse spaces.
export function normalizeKey(raw: string): string {
  return raw
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .trim();
}

// ─── Languages ─────────────────────────────────────────────

export const LANGUAGES: Named[] = [
  { id: 'ar', nameAr: 'العربية', nameEn: 'Arabic' },
  { id: 'en', nameAr: 'الإنجليزية', nameEn: 'English' },
  { id: 'ko', nameAr: 'الكورية', nameEn: 'Korean' },
];

// ─── Edition types ─────────────────────────────────────────

export const EDITION_TYPES: Ordered[] = [
  { id: 'standard', nameAr: 'طبعة عادية', nameEn: 'Standard edition', sortOrder: 0 },
  { id: 'international', nameAr: 'طبعة عالمية', nameEn: 'International edition', sortOrder: 1 },
  { id: 'teacher', nameAr: 'طبعة المدرسين', nameEn: "Teacher's edition", sortOrder: 2 },
  { id: 'unspecified', nameAr: 'غير محددة', nameEn: 'Not specified', sortOrder: 3 },
];

// ─── Article types ─────────────────────────────────────────

export const ARTICLE_TYPES: Ordered[] = [
  { id: 'article', nameAr: 'مقال', nameEn: 'Article', sortOrder: 0 },
  { id: 'research', nameAr: 'بحث', nameEn: 'Research paper', sortOrder: 1 },
  { id: 'review', nameAr: 'مقال مراجعة', nameEn: 'Review article', sortOrder: 2 },
  { id: 'conference-paper', nameAr: 'بحث مؤتمر', nameEn: 'Conference paper', sortOrder: 3 },
  { id: 'opinion', nameAr: 'مقال رأي', nameEn: 'Opinion piece', sortOrder: 4 },
  { id: 'guide', nameAr: 'مقال إرشادي', nameEn: 'Guide', sortOrder: 5 },
];

/// The sheet's 15 spellings of "نوع الوثيقة" folded into the six above.
/// "Research article" wordings (مقال بحثي, مقالة بحثية) count as research;
/// the dataset itself separates them from the plain-article rows.
export const ARTICLE_TYPE_BY_SHEET_NAME: Record<string, string> = {
  مقال: 'article',
  'مقال علمي': 'article',
  بحث: 'research',
  'بحث أصلي': 'research',
  'بحث تجريبي': 'research',
  'بحث تطبيقي': 'research',
  'بحث علمي (مقالة دورية)': 'research',
  'مقال بحثي': 'research',
  'مقالة بحثية': 'research',
  'مقال مراجعة': 'review',
  'مقالة مراجعة': 'review',
  'بحث مراجعة': 'review',
  'بحث مؤتمر': 'conference-paper',
  'مقال رأي': 'opinion',
  'مقال إرشادي': 'guide',
};

// ─── Source types ──────────────────────────────────────────

export const SOURCE_TYPES: Named[] = [
  { id: 'journal', nameAr: 'مجلة', nameEn: 'Journal' },
  { id: 'conference', nameAr: 'مؤتمر', nameEn: 'Conference' },
];

export const SOURCE_TYPE_BY_SHEET_NAME: Record<string, string> = {
  مجلة: 'journal',
  مؤتمر: 'conference',
};
