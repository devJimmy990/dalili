/**
 * Seeds the database from the curated spreadsheet (`data/Dalili.xlsx`).
 *
 * The sheet is the librarians' working copy, so it carries a few quirks
 * this script normalizes rather than pushing downstream:
 *
 *   1. `Books.department_id` uses short codes (d1..d5) while the
 *      Departments sheet uses slugs (d_electrical...). DEPARTMENT_ALIASES
 *      bridges the two; an unmapped code aborts the seed.
 *   2. `Books.location` duplicates `department_id` and is dropped — a
 *      book's location is its department's spot on the library map.
 *   3. Ordinals arrive as "3rd" / "Null" / "international". Numbers are
 *      stored as integers; anything else survives in `editionLabel`.
 *   4. `year` sometimes reads "[2001]".
 *   5. `Articles.book_ids` packs several ids with a "/*-*\/" separator.
 *
 * Idempotent: upserts everything and re-links articles, so it is safe to
 * re-run after editing the sheet.
 *
 * `npm run seed -- --dry-run` parses and validates the sheet, prints what
 * it would write, and never opens a database connection.
 */
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PrismaClient } from '@prisma/client';
import * as XLSX from 'xlsx';

const here = dirname(fileURLToPath(import.meta.url));
const XLSX_PATH = resolve(here, '../data/Dalili.xlsx');
const MAP_PATH = resolve(here, '../../mobile/assets/map/library_map.json');

const BOOK_IDS_SEPARATOR = '/*-*/';

/// Short codes used in the Books sheet → canonical department slugs.
/// Derived from the books themselves (d1 is all electrical engineering,
/// d2 architecture, and so on).
const DEPARTMENT_ALIASES: Record<string, string> = {
  d1: 'd_electrical',
  d2: 'd_architecture',
  d3: 'd_civil',
  d4: 'd_mechanical',
  d5: 'd_basic_sciences',
};

/// Departments that share another section's spot on the library map.
/// Basic Sciences sits with Mechanical Engineering, and the map has no
/// node of its own for it — navigation routes to the shared node.
const MAP_NODE_OVERRIDES: Record<string, string> = {
  d_basic_sciences: 'd_mechanical',
};

/// ISBNs Excel stored as a float and rounded, losing the trailing digits
/// (`9788120000000`). Kept as-is — the digits are gone from the source —
/// but reported so the sheet can be fixed later by formatting the column
/// as Text. A real ISBN never ends in this many zeros.
const TRUNCATED_ISBN = /0{5,}$/;

const DRY_RUN = process.argv.includes('--dry-run');

// PrismaClient validates the datasource URL at construction, so a dry run
// on a machine with no .env gets a placeholder it will never dial.
if (DRY_RUN && !process.env.DATABASE_URL) {
  process.env.DATABASE_URL = 'postgresql://dry:run@127.0.0.1:5432/dryrun';
}

const prisma = new PrismaClient();

// ─── Cell helpers ──────────────────────────────────────────

type Row = Record<string, unknown>;

function str(row: Row, key: string): string {
  const v = row[key];
  if (v === null || v === undefined) return '';
  return String(v).trim();
}

/// A blank cell means "we don't know", not "the value is an empty string",
/// so it becomes NULL. "Null" typed literally by hand counts as blank too.
function nullable(row: Row, key: string): string | null {
  const v = str(row, key);
  return v.length === 0 || /^null$/i.test(v) ? null : v;
}

/// "[2001]" → 2001, "" → null. Rejects anything outside a sane range so
/// a stray cell cannot land in the database as a year.
function year(raw: string): number | null {
  const digits = raw.replace(/[^0-9]/g, '');
  if (digits.length !== 4) return null;
  const n = Number(digits);
  return n >= 1000 && n <= 2100 ? n : null;
}

/// "3rd" → 3, "1st" → 1, "Null"/"international" → null.
function ordinal(raw: string): number | null {
  if (!raw || /^null$/i.test(raw)) return null;
  const m = /^(\d{1,2})\s*(st|nd|rd|th)?$/i.exec(raw);
  if (!m?.[1]) return null;
  const n = Number(m[1]);
  return n >= 1 && n <= 20 ? n : null;
}

/// Keeps a non-numeric edition as free text ("international", "teacher").
function editionFallback(raw: string, parsed: number | null): string | null {
  if (parsed !== null) return null;
  if (!raw || /^null$/i.test(raw)) return null;
  return raw;
}

/// Note the blank check: Number('') is 0, which would silently rank an
/// unscored article as the least relevant instead of unranked.
function score(raw: string): number | null {
  if (raw.length === 0) return null;
  const n = Number(raw);
  return Number.isFinite(n) ? n : null;
}

function splitBookIds(raw: string): string[] {
  return raw
    .split(BOOK_IDS_SEPARATOR)
    .flatMap((part) => part.split(','))
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

function readSheet(wb: XLSX.WorkBook, name: string): Row[] {
  const sheet = wb.Sheets[name];
  if (!sheet) throw new Error(`Sheet "${name}" not found in ${XLSX_PATH}`);
  return XLSX.utils
    .sheet_to_json<Row>(sheet, { defval: '', raw: true })
    .filter((row) => str(row, 'id') !== '');
}

/// Node ids present in the app's map asset, so a department can only
/// claim a `mapNodeId` that navigation can actually route to.
function readMapNodeIds(): Set<string> {
  try {
    const map = JSON.parse(readFileSync(MAP_PATH, 'utf8')) as { nodes?: { id?: string }[] };
    return new Set((map.nodes ?? []).flatMap((n) => (n.id ? [n.id] : [])));
  } catch {
    console.warn(`  ! could not read ${MAP_PATH} — mapNodeId will be left null`);
    return new Set();
  }
}

// ─── Seed ──────────────────────────────────────────────────

async function main(): Promise<void> {
  console.log(DRY_RUN ? `Dry run — reading ${XLSX_PATH}, nothing will be written` : `Reading ${XLSX_PATH}`);
  const wb = XLSX.readFile(XLSX_PATH);

  const departmentRows = readSheet(wb, 'Departments');
  const placeRows = readSheet(wb, 'Places');
  const bookRows = readSheet(wb, 'Books');
  const articleRows = readSheet(wb, 'Articles');
  const mapNodeIds = readMapNodeIds();

  // ── Departments ──
  const departments = departmentRows.map((row, i) => {
    const id = str(row, 'id');
    const node = MAP_NODE_OVERRIDES[id] ?? id;
    return {
      id,
      nameAr: str(row, 'name_ar'),
      nameEn: str(row, 'name_en'),
      mapNodeId: mapNodeIds.has(node) ? node : null,
      sortOrder: i,
    };
  });
  const departmentIds = new Set(departments.map((d) => d.id));

  if (!DRY_RUN) {
    for (const d of departments) {
      await prisma.department.upsert({ where: { id: d.id }, create: d, update: d });
    }
  }
  console.log(`  departments: ${departments.length}`);
  const unmapped = departments.filter((d) => d.mapNodeId === null);
  if (unmapped.length > 0) {
    console.warn(
      `  ! no map node for: ${unmapped.map((d) => d.id).join(', ')} — ` +
        'navigation to these sections is disabled until library_map.json gains a node with the same id',
    );
  }

  // ── Places ──
  const places = placeRows.map((row) => ({
    id: str(row, 'id'),
    nameAr: str(row, 'place_ar'),
    nameEn: str(row, 'place_en'),
  }));
  if (!DRY_RUN) {
    for (const p of places) {
      await prisma.place.upsert({ where: { id: p.id }, create: p, update: p });
    }
  }
  console.log(`  places: ${places.length}`);

  // ── Books ──
  const books = bookRows.map((row) => {
    const rawDept = str(row, 'department_id');
    const departmentId = DEPARTMENT_ALIASES[rawDept] ?? rawDept;
    if (!departmentIds.has(departmentId)) {
      throw new Error(
        `Book ${str(row, 'id')} has department_id "${rawDept}" which matches no department. ` +
          'Fix the sheet or add an entry to DEPARTMENT_ALIASES.',
      );
    }

    const rawEdition = str(row, 'edition');
    const edition = ordinal(rawEdition);
    const placeId = str(row, 'place_id');

    // These four are NOT NULL in the schema; a blank one is a broken row,
    // not a book with an unknown title.
    for (const field of ['call_number', 'title', 'author', 'department_id']) {
      if (str(row, field).length === 0) {
        throw new Error(`Book ${str(row, 'id')} is missing required column "${field}"`);
      }
    }

    return {
      id: str(row, 'id'),
      callNumber: str(row, 'call_number'),
      title: str(row, 'title'),
      author: str(row, 'author'),
      edition,
      editionLabel: editionFallback(rawEdition, edition),
      publisher: nullable(row, 'publisher'),
      year: year(str(row, 'year')),
      subjects: nullable(row, 'subjects'),
      shelf: ordinal(str(row, 'shelf')),
      language: nullable(row, 'language'),
      cover: nullable(row, 'cover'),
      isbn: nullable(row, 'isbn'),
      placeId: placeId.length > 0 ? placeId : null,
      departmentId,
    };
  });

  const knownPlaceIds = new Set(places.map((p) => p.id));
  const orphanPlaces = [...new Set(books.flatMap((b) => (b.placeId && !knownPlaceIds.has(b.placeId) ? [b.placeId] : [])))];
  if (orphanPlaces.length > 0) {
    throw new Error(`Books reference unknown place_id: ${orphanPlaces.join(', ')}`);
  }

  if (!DRY_RUN) {
    for (const b of books) {
      await prisma.book.upsert({ where: { id: b.id }, create: b, update: b });
    }
  }
  console.log(`  books: ${books.length}`);

  const truncated = books.filter((b) => b.isbn !== null && TRUNCATED_ISBN.test(b.isbn));
  if (truncated.length > 0) {
    console.warn(`  ! ${truncated.length} book(s) have an ISBN Excel rounded off — format the column as Text and re-seed:`);
    for (const b of truncated) console.warn(`      ${b.id}  ${b.isbn}  ${b.title.slice(0, 48)}`);
  }

  // ── Articles + links ──
  const bookIds = new Set(books.map((b) => b.id));
  const links: { bookId: string; articleId: string }[] = [];
  const orphanLinks: string[] = [];

  const articles = articleRows.map((row) => {
    const id = str(row, 'id');
    if (str(row, 'title').length === 0) {
      throw new Error(`Article ${id} is missing required column "title"`);
    }
    for (const bookId of splitBookIds(str(row, 'book_ids'))) {
      if (bookIds.has(bookId)) links.push({ bookId, articleId: id });
      else orphanLinks.push(`${id} → ${bookId}`);
    }

    return {
      id,
      title: str(row, 'title'),
      authors: nullable(row, 'authors'),
      sourceTitle: nullable(row, 'source_title'),
      keywords: nullable(row, 'keywords'),
      doi: nullable(row, 'doi'),
      year: year(str(row, 'year')),
      type: nullable(row, 'type'),
      source: nullable(row, 'source'),
      issn: nullable(row, 'issn'),
      volume: nullable(row, 'volume'),
      issue: nullable(row, 'issue'),
      pages: nullable(row, 'pages'),
      score: score(str(row, 'score')),
      url: nullable(row, 'url'),
    };
  });

  if (!DRY_RUN) {
    for (const a of articles) {
      await prisma.article.upsert({ where: { id: a.id }, create: a, update: a });
    }
  }
  console.log(`  articles: ${articles.length}`);

  // Rebuild the join table so links removed from the sheet disappear too.
  if (!DRY_RUN) {
    await prisma.bookArticle.deleteMany({});
    await prisma.bookArticle.createMany({ data: links, skipDuplicates: true });
  }
  console.log(`  book↔article links: ${links.length}`);
  if (orphanLinks.length > 0) {
    console.warn(`  ! ${orphanLinks.length} article link(s) point to a missing book: ${orphanLinks.join(', ')}`);
  }

  const booksWithoutArticles = books.filter((b) => !links.some((l) => l.bookId === b.id)).length;
  if (booksWithoutArticles > 0) {
    console.log(`  note: ${booksWithoutArticles} book(s) have no linked articles`);
  }

  console.log(DRY_RUN ? 'Dry run complete — the sheet is valid, no rows written.' : 'Seed complete.');
}

main()
  .catch((err) => {
    console.error('Seed failed:', err instanceof Error ? err.message : err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
