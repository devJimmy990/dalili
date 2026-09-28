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

// ─── Ordinals ──────────────────────────────────────────────
// Edition is feminine in Arabic (الطبعة الأولى), shelf is masculine
// (الرف الأول) — hence two tables for the same numbers.

const ORDINAL_EN: Record<number, string> = {
  1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th',
  6: '6th', 7: '7th', 8: '8th', 9: '9th', 10: '10th',
};

const EDITION_AR: Record<number, string> = {
  1: 'الأولى', 2: 'الثانية', 3: 'الثالثة', 4: 'الرابعة', 5: 'الخامسة',
  6: 'السادسة', 7: 'السابعة', 8: 'الثامنة', 9: 'التاسعة', 10: 'العاشرة',
};

const SHELF_AR: Record<number, string> = {
  1: 'الأول', 2: 'الثاني', 3: 'الثالث', 4: 'الرابع', 5: 'الخامس',
  6: 'السادس', 7: 'السابع', 8: 'الثامن', 9: 'التاسع', 10: 'العاشر',
};

function ordinal(table: Record<number, string>, n: number, lang: Lang): string {
  const map = lang === 'en' ? ORDINAL_EN : table;
  return map[n] ?? String(n);
}

/// "الثالثة" / "3rd". `fallback` carries non-numeric editions ("international").
export function editionLabel(n: number | null, fallback: string | null, lang: Lang): string | null {
  if (n !== null) return ordinal(EDITION_AR, n, lang);
  return fallback && fallback.length > 0 ? fallback : null;
}

/// "الثالث" / "3rd".
export function shelfLabel(n: number | null, lang: Lang): string | null {
  return n === null ? null : ordinal(SHELF_AR, n, lang);
}
