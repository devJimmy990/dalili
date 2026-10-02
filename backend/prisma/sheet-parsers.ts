/**
 * Pure functions that turn one hand-typed spreadsheet cell into a clean
 * value. No I/O and no Prisma, so they can be unit-tested on their own
 * (`npm test`) and the seed stays a thin loop around them.
 *
 * Every parser either returns a value, returns null for "the sheet does not
 * say", or throws on something it does not recognise — a new spelling must
 * stop the seed so a person decides what it means, not slip in as garbage.
 */
import { LANGUAGES, normalizeKey } from './lookups.js';

export type Cell = unknown;

/// A cell as trimmed text; numbers keep their digits, blanks become ''.
export function text(cell: Cell): string {
  if (cell === null || cell === undefined) return '';
  return String(cell).replace(/\s+/g, ' ').trim();
}

/// Blank, or a hand-typed "null", means "unknown" → NULL.
export function nullable(cell: Cell): string | null {
  const v = text(cell);
  return v.length === 0 || /^null$/i.test(v) ? null : v;
}

export function integer(cell: Cell): number | null {
  const v = text(cell);
  if (!/^\d+$/.test(v)) return null;
  return Number(v);
}

/// "[2001]" → 2001. Rejects anything outside a sane range.
export function year(cell: Cell): number | null {
  const digits = text(cell).replace(/[^0-9]/g, '');
  if (digits.length !== 4) return null;
  const n = Number(digits);
  return n >= 1000 && n <= 2100 ? n : null;
}

// ─── Books ─────────────────────────────────────────────────

/// MARC punctuation leaks into the sheet: "Electric machines :" → "Electric machines".
export function title(cell: Cell): string {
  return text(cell).replace(/[\s:/;,]+$/, '');
}

/// "Kumar, K. Murugesh." stays as is; a trailing comma goes, and the
/// "[ بدون مؤلف ]" placeholder means there is no author on record.
export function author(cell: Cell): string | null {
  const v = text(cell).replace(/[\s,،]+$/, '');
  if (v.length === 0 || /^\[?\s*بدون مؤلف\s*\]?$/.test(v)) return null;
  return v;
}

/// "Wiley," → "Wiley", "[Cengage Learning]" → "Cengage Learning".
export function publisher(cell: Cell): string | null {
  const v = text(cell)
    .replace(/^\[(.*)\]$/, '$1')
    .replace(/[\s,;،]+$/, '');
  return v.length === 0 ? null : v;
}

/// Subject headings arrive with a dangling MARC dash: "Machinery -".
export function subjects(cell: Cell): string | null {
  const v = text(cell).replace(/[\s,;-]+$/, '');
  return v.length === 0 ? null : v;
}

/// Same publisher typed in different case ("springer", "Springer") should
/// be one name. Picks, per case-insensitive key, the spelling with the most
/// capitals that is not ALL CAPS.
export function publisherCanonicalizer(names: (string | null)[]): (name: string | null) => string | null {
  const best = new Map<string, string>();
  const score = (s: string) => (s === s.toUpperCase() ? -1 : (s.match(/\p{Lu}/gu) ?? []).length);
  for (const n of names) {
    if (!n) continue;
    const key = n.toLowerCase();
    const current = best.get(key);
    if (current === undefined || score(n) > score(current)) best.set(key, n);
  }
  return (name) => (name ? (best.get(name.toLowerCase()) ?? name) : null);
}

// ─── ISBN ──────────────────────────────────────────────────

export type IsbnNote = 'padded' | 'bad-checksum';

function isbn10Valid(s: string): boolean {
  if (!/^\d{9}[\dX]$/.test(s)) return false;
  let sum = 0;
  for (let i = 0; i < 10; i++) sum += (s[i] === 'X' ? 10 : Number(s[i])) * (10 - i);
  return sum % 11 === 0;
}

function isbn13Valid(s: string): boolean {
  if (!/^\d{13}$/.test(s)) return false;
  let sum = 0;
  for (let i = 0; i < 13; i++) sum += Number(s[i]) * (i % 2 === 0 ? 1 : 3);
  return sum % 10 === 0;
}

/// Excel stores ISBN-10s with a leading zero as numbers and drops it
/// ("0521781752" → 521781752). A value shorter than 10 digits is restored by
/// left-padding, but only when the padded number is a *valid* ISBN-10 — a
/// guess that fails the checksum is left alone and reported.
export function isbn(cell: Cell): { value: string | null; note?: IsbnNote } {
  const v = text(cell).replace(/[\s-]/g, '').toUpperCase();
  if (v.length === 0) return { value: null };
  if (/^\d{1,9}$/.test(v)) {
    const padded = v.padStart(10, '0');
    return isbn10Valid(padded) ? { value: padded, note: 'padded' } : { value: v, note: 'bad-checksum' };
  }
  if (isbn10Valid(v) || isbn13Valid(v)) return { value: v };
  return { value: v, note: 'bad-checksum' };
}

// ─── Edition ───────────────────────────────────────────────

export interface Edition {
  /// Edition number, when the record states one.
  number: number | null;
  /// Lookup id in edition_types.
  typeId: 'standard' | 'international' | 'teacher' | 'unspecified';
  /// Printed in [brackets]: supplied by the cataloguer, not on the book.
  inferred: boolean;
}

/// Understands every spelling in the sheet:
///   "2nd. ed" · "[1st. ed]" · "[2st. ed]" (typo) · "ط. 1" · "[د.ط]" (no edition)
///   "International edition." · "Teacher ed."
export function edition(cell: Cell): Edition {
  const raw = text(cell);
  const bracketed = /^\[.*\]$/.test(raw);
  const v = raw.replace(/^\[|\]$/g, '').trim();

  if (v.length === 0 || /^null$/i.test(v) || v.replace(/\s/g, '') === 'د.ط') {
    return { number: null, typeId: 'unspecified', inferred: bracketed };
  }
  let m = /^(\d{1,2})\s*(?:st|nd|rd|th)\.?\s*ed\.?$/i.exec(v);
  if (m?.[1]) return { number: Number(m[1]), typeId: 'standard', inferred: bracketed };
  m = /^ط\.?\s*(\d{1,2})$/.exec(v);
  if (m?.[1]) return { number: Number(m[1]), typeId: 'standard', inferred: bracketed };
  if (/^international\b/i.test(v)) return { number: null, typeId: 'international', inferred: bracketed };
  if (/^teachers?\b/i.test(v)) return { number: null, typeId: 'teacher', inferred: bracketed };
  throw new Error(`Unrecognised edition "${raw}"`);
}

// ─── Language ──────────────────────────────────────────────

export interface BookLanguageLink {
  languageId: string;
  role: 'TEXT' | 'TRANSLATED_FROM';
  position: number;
}

const LANGUAGE_BY_NAME = new Map(LANGUAGES.map((l) => [l.nameAr, l.id]));

function languageId(name: string): string {
  const id = LANGUAGE_BY_NAME.get(name.trim());
  if (!id) throw new Error(`Unrecognised language "${name}"`);
  return id;
}

/// "العربية (مترجم عن الإنجليزية)" → Arabic text, translated from English.
/// "الكورية والإنجليزية"           → Korean and English text.
export function languages(cell: Cell): BookLanguageLink[] {
  const raw = text(cell);
  if (raw.length === 0) return [];

  const translated = /^(.*?)\s*\(\s*مترجم عن\s+(.+?)\s*\)$/.exec(raw);
  const main = translated ? (translated[1] ?? '') : raw;

  const links: BookLanguageLink[] = main
    .split(/[،,+]|\s+و(?=ال)/)
    .map((part) => part.trim())
    .filter((part) => part.length > 0)
    .map((part, position) => ({ languageId: languageId(part), role: 'TEXT' as const, position }));

  if (translated?.[2]) {
    links.push({ languageId: languageId(translated[2]), role: 'TRANSLATED_FROM', position: links.length });
  }
  return links;
}

// ─── Place ─────────────────────────────────────────────────

export function placeKey(cell: Cell): string {
  return normalizeKey(text(cell));
}
