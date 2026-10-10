export type Lang = 'ar' | 'en';

/** Arabic for Arabic browsers (and `?lang=ar`), English otherwise. */
export function detectLang(search: string, browserLanguage: string): Lang {
  const asked = new URLSearchParams(search).get('lang');
  if (asked === 'ar' || asked === 'en') return asked;
  return browserLanguage.toLowerCase().startsWith('ar') ? 'ar' : 'en';
}

const strings = {
  ar: {
    appName: 'دليلي',
    tagline: 'مساعد المكتبة الذكي',
    loading: 'جاري تحميل الكتاب…',
    waking: 'السيرفر بيصحى، ثواني وهيفتح…',
    notFoundTitle: 'الكتاب غير موجود',
    notFoundBody: 'الرابط ده مش مرتبط بأي كتاب في المكتبة. اتأكد إنه اتنسخ كامل.',
    errorTitle: 'تعذّر تحميل الكتاب',
    errorBody: 'في مشكلة في الاتصال. جرّب تاني بعد شوية.',
    retry: 'إعادة المحاولة',
    notBookTitle: 'رابط غير صالح',
    notBookBody: 'الرابط ده مش رابط كتاب من دليلي.',
    location: 'الموقع',
    callNumber: 'رقم التصنيف',
    bibid: 'BibID',
    isbn: 'الترقيم الدولي',
    publisher: 'الناشر',
    place: 'مكان النشر',
    year: 'السنة',
    edition: 'الطبعة',
    language: 'اللغة',
    openInApp: 'افتح في التطبيق',
    getApp: 'حمّل تطبيق دليلي',
    appHint: 'التطبيق بيوصّلك لمكان الكتاب جوه المكتبة خطوة بخطوة.',
    relatedArticles: 'مقالات ذات صلة',
    closeArticles: 'إغلاق',
    relevance: 'نسبة الارتباط',
    doi: 'DOI',
    opensInNewTab: 'يُفتح في تبويب جديد',
  },
  en: {
    appName: 'Dalili',
    tagline: 'Smart library assistant',
    loading: 'Loading the book…',
    waking: 'The server is waking up — this takes a few seconds…',
    notFoundTitle: 'Book not found',
    notFoundBody: 'This link is not tied to any book in the library. Make sure it was copied in full.',
    errorTitle: 'Could not load the book',
    errorBody: 'There is a connection problem. Please try again in a moment.',
    retry: 'Try again',
    notBookTitle: 'Invalid link',
    notBookBody: 'This is not a Dalili book link.',
    location: 'Location',
    callNumber: 'Call number',
    bibid: 'BibID',
    isbn: 'ISBN',
    publisher: 'Publisher',
    place: 'Place of publication',
    year: 'Year',
    edition: 'Edition',
    language: 'Language',
    openInApp: 'Open in app',
    getApp: 'Get the Dalili app',
    appHint: 'The app walks you to the book inside the library, step by step.',
    relatedArticles: 'Related articles',
    closeArticles: 'Close',
    relevance: 'Relevance',
    doi: 'DOI',
    opensInNewTab: 'Opens in a new tab',
  },
} as const;

/** Every key, as plain text — not the literal wording of one language. */
export type Strings = Record<keyof (typeof strings)['ar'], string>;

export const t = (lang: Lang): Strings => strings[lang];
export const dir = (lang: Lang): 'rtl' | 'ltr' => (lang === 'ar' ? 'rtl' : 'ltr');
