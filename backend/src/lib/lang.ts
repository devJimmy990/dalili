// Localization helpers shared by every route.
//
// Two locales only: "ar" (default) and "en". A request picks one with
// `?lang=`; anything unrecognized falls back to Arabic.

export const LANGS = ['ar', 'en'] as const;
export type Lang = (typeof LANGS)[number];

export function resolveLang(raw: unknown): Lang {
  return LANGS.includes(raw as Lang) ? (raw as Lang) : 'ar';
}

/// Error messages returned to the client.
const MESSAGES = {
  ar: {
    book_not_found: 'لم يتم العثور على الكتاب',
    department_not_found: 'لم يتم العثور على القسم',
    missing_query: 'معامل البحث مفقود',
    invalid_request: 'طلب غير صالح',
    not_found: 'المسار غير موجود',
    server_error: 'خطأ في الخادم',
  },
  en: {
    book_not_found: 'Book not found',
    department_not_found: 'Department not found',
    missing_query: 'Missing query parameter',
    invalid_request: 'Invalid request',
    not_found: 'Route not found',
    server_error: 'Server error',
  },
} satisfies Record<Lang, Record<string, string>>;

export type MessageKey = keyof (typeof MESSAGES)['ar'];

export function msg(lang: Lang, key: MessageKey): string {
  return MESSAGES[lang][key];
}

// ─── Labels ────────────────────────────────────────────────
// Everything below turns stored ids/numbers into the sentence a reader
// sees. Names that live in lookup tables are resolved by `pick`; only the
// connecting words ("shelf", "department", ...) are defined here.

/// A lookup row (department, language, edition type...) in the active language.
export function pick(row: { nameAr: string; nameEn: string }, lang: Lang): string {
  return lang === 'en' ? row.nameEn : row.nameAr;
}

const ORDINAL_EN: Record<number, string> = {
  1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th',
  6: '6th', 7: '7th', 8: '8th', 9: '9th', 10: '10th',
};

/// "ط. 3" / "3rd"; kinds other than a plain numbered edition are named
/// ("طبعة عالمية" / "International edition"). A record with no edition at all
/// ("[د.ط]") has no label, so the app hides the row.
///
/// `inferred` is the sheet's "[1st. ed]": the number is the cataloguer's
/// assumption, not something printed on the book, so it is not shown as
/// the same fact as "1st. ed" — it keeps its brackets: "[ط. 1]" / "[1st]".
export function editionLabel(
  n: number | null,
  type: { id: string; nameAr: string; nameEn: string } | null,
  lang: Lang,
  inferred = false,
): string | null {
  const parts: string[] = [];
  if (type && type.id !== 'standard' && type.id !== 'unspecified') parts.push(pick(type, lang));
  if (n !== null) parts.push(lang === 'en' ? (ORDINAL_EN[n] ?? String(n)) : `ط. ${n}`);
  if (parts.length === 0) return null;
  const label = parts.join(' - ');
  if (!inferred) return label;
  return `[${label}]`;
}

/// Shelf numbers are library-wide codes printed on the stacks, so they are
/// shown as-is, not as an ordinal: "الرف 31" / "Shelf 31".
export function shelfLabel(n: number | null, lang: Lang): string | null {
  if (n === null) return null;
  return lang === 'en' ? `Shelf ${n}` : `الرف ${n}`;
}

/// "قسم كهرباء، الرف 31" / "Electrical Engineering Department, Shelf 31".
export function locationLabel(departmentName: string, shelf: number | null, lang: Lang): string {
  const dept = lang === 'en' ? `${departmentName} Department` : `قسم ${departmentName}`;
  const shelfText = shelfLabel(shelf, lang);
  return shelfText ? `${dept}${lang === 'en' ? ', ' : '، '}${shelfText}` : dept;
}

export interface LanguageLink {
  role: 'TEXT' | 'TRANSLATED_FROM';
  language: { id: string; nameAr: string; nameEn: string };
}

/// "الكورية والإنجليزية" · "العربية (مترجم عن الإنجليزية)" ·
/// "Korean and English" · "Arabic (translated from English)".
export function languageLabel(links: LanguageLink[], lang: Lang): string | null {
  const text = links.filter((l) => l.role === 'TEXT').map((l) => pick(l.language, lang));
  if (text.length === 0) return null;
  const joined = lang === 'en' ? text.join(' and ') : text.join(' و');
  const from = links.find((l) => l.role === 'TRANSLATED_FROM');
  if (!from) return joined;
  const source = pick(from.language, lang);
  return lang === 'en' ? `${joined} (translated from ${source})` : `${joined} (مترجم عن ${source})`;
}

/// Shown when a record has no author, so a book card never has a blank line.
export function unknownAuthor(lang: Lang): string {
  return lang === 'en' ? 'Unknown author' : 'مؤلف غير معروف';
}
