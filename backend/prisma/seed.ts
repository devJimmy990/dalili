/**
 * Seeds the database from the librarians' spreadsheet (`data/Datasource.xlsx`,
 * sheets `books` and `articles`).
 *
 * The sheet is a hand-kept working copy, so this script normalizes it rather
 * than pushing quirks downstream (the cell-level rules live in
 * sheet-parsers.ts and lookups.ts):
 *
 *   1. Sections and cities come from reference-data.ts — the sheet only
 *      names them, and every name must resolve to an existing row.
 *   2. Language, edition and document type are lookup tables with Arabic and
 *      English names; the books/articles store ids.
 *   3. "BibID" is the book id. The articles sheet has no id of its own, so
 *      each gets a stable one derived from its DOI (or title).
 *   4. The same article listed under two books becomes ONE article linked
 *      to both.
 *   5. A conference-sourced document is always a conference paper, whatever
 *      its "نوع الوثيقة" says.
 *
 * Idempotent: upserts everything, rebuilds the join tables and removes rows
 * the sheet no longer has, so it is safe to re-run after editing the sheet.
 *
 * `npm run seed -- --dry-run` parses and validates the sheet, prints what
 * it would write and what it had to repair, and never opens a database
 * connection.
 */
import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PrismaClient } from '@prisma/client';
import * as XLSX from 'xlsx';
import {
  ARTICLE_TYPES,
  ARTICLE_TYPE_BY_SHEET_NAME,
  DEPARTMENT_BY_SHEET_NAME,
  EDITION_TYPES,
  LANGUAGES,
  PLACE_BY_SHEET_NAME,
  SOURCE_TYPES,
  SOURCE_TYPE_BY_SHEET_NAME,
} from './lookups.js';
import * as parse from './sheet-parsers.js';
import { DEPARTMENTS, PLACES } from './reference-data.js';

const here = dirname(fileURLToPath(import.meta.url));
const XLSX_PATH = resolve(here, '../data/Datasource.xlsx');
const MAP_PATH = resolve(here, '../../mobile/assets/map/library_map.json');

/// Departments that share another section's spot on the library map.
/// Basic Sciences sits with Mechanical Engineering, and the map has no
/// node of its own for it — navigation routes to the shared node.
const MAP_NODE_OVERRIDES: Record<string, string> = {
  d_basic_sciences: 'd_mechanical',
};

const DRY_RUN = process.argv.includes('--dry-run');

// PrismaClient validates the datasource URL at construction, so a dry run
// on a machine with no .env gets a placeholder it will never dial.
if (DRY_RUN && !process.env.DATABASE_URL) {
  process.env.DATABASE_URL = 'postgresql://dry:run@127.0.0.1:5432/dryrun';
}

const prisma = new PrismaClient();

// ─── Sheet access ──────────────────────────────────────────

type Row = Record<string, unknown>;

/// Header names are matched trimmed: the sheet has " المجموعة المنتمي إليها "
/// with stray spaces, and a re-export may add or drop them.
function readSheet(wb: XLSX.WorkBook, name: string): Row[] {
  const sheet = wb.Sheets[name];
  if (!sheet) throw new Error(`Sheet "${name}" not found in ${XLSX_PATH}`);
  return XLSX.utils.sheet_to_json<Row>(sheet, { defval: '', raw: true }).map((row) => {
    const trimmed: Row = {};
    for (const [key, value] of Object.entries(row)) trimmed[key.trim()] = value;
    return trimmed;
  });
}

function requireColumns(rows: Row[], sheet: string, columns: string[]): void {
  const have = new Set(Object.keys(rows[0] ?? {}));
  const missing = columns.filter((c) => !have.has(c));
  if (missing.length > 0) throw new Error(`Sheet "${sheet}" is missing column(s): ${missing.join(', ')}`);
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

function lookup(map: Record<string, string>, raw: string, what: string, owner: string): string {
  const id = map[raw.trim()];
  if (!id) throw new Error(`${owner}: unknown ${what} "${raw}". Add it to prisma/lookups.ts.`);
  return id;
}

/// Stable across re-seeds, so a favorited article keeps its id.
function articleId(doi: string | null, titleText: string): string {
  const basis = (doi ?? titleText).toLowerCase().replace(/\s+/g, ' ').trim();
  return `a_${createHash('sha1').update(basis).digest('hex').slice(0, 10)}`;
}

// ─── Build (pure: no database) ─────────────────────────────

interface Report {
  editionInferred: string[];
  isbnPadded: string[];
  isbnBad: string[];
  noAuthor: string[];
  placeIsBinding: string[];
  mergedArticles: string[];
  reclassified: string[];
  noIssn: number;
}

function buildBooks(rows: Row[], report: Report) {
  requireColumns(rows, 'books', [
    'BibID', 'رقم الاستدعاء', 'العنوان', 'المؤلف', 'الطبعة', 'الناشر', 'سنة النشر', 'مكان النشر',
    'ISBN', 'رؤوس الموضوعات', 'الموقع على الرف', 'المجموعة المنتمي إليها', 'اللغة', 'الغلاف',
  ]);

  const canonicalPublisher = parse.publisherCanonicalizer(rows.map((r) => parse.publisher(r['الناشر'])));
  const seen = new Set<string>();

  return rows.map((row) => {
    const id = parse.text(row['BibID']);
    if (id.length === 0) throw new Error('A book row has no BibID');
    if (seen.has(id)) throw new Error(`Duplicate BibID ${id}`);
    seen.add(id);

    const callNumber = parse.text(row['رقم الاستدعاء']);
    const bookTitle = parse.title(row['العنوان']);
    if (callNumber.length === 0 || bookTitle.length === 0) {
      throw new Error(`Book ${id} is missing its call number or title`);
    }

    const departmentId = lookup(DEPARTMENT_BY_SHEET_NAME, parse.text(row['المجموعة المنتمي إليها']), 'department', `Book ${id}`);
    const placeRaw = parse.text(row['مكان النشر']);
    const placeId = placeRaw ? PLACE_BY_SHEET_NAME[parse.placeKey(placeRaw)] : undefined;
    if (placeRaw && !placeId) throw new Error(`Book ${id}: unknown place "${placeRaw}". Add it to PLACE_BY_SHEET_NAME.`);
    if (placeId === 'hardcover' || placeId === 'paperback') report.placeIsBinding.push(`${id} (${placeRaw})`);

    const ed = parse.edition(row['الطبعة']);
    if (ed.inferred && ed.typeId !== 'unspecified') report.editionInferred.push(`${id} "${parse.text(row['الطبعة'])}"`);

    const code = parse.isbn(row['ISBN']);
    if (code.note === 'padded') report.isbnPadded.push(`${id} ${parse.text(row['ISBN'])} → ${code.value}`);
    if (code.note === 'bad-checksum') report.isbnBad.push(`${id} ${code.value}`);

    const bookAuthor = parse.author(row['المؤلف']);
    if (bookAuthor === null) report.noAuthor.push(id);

    return {
      id,
      callNumber,
      title: bookTitle,
      author: bookAuthor,
      editionNumber: ed.number,
      editionTypeId: ed.typeId,
      editionInferred: ed.inferred,
      publisher: canonicalPublisher(parse.publisher(row['الناشر'])),
      year: parse.year(row['سنة النشر']),
      subjects: parse.subjects(row['رؤوس الموضوعات']),
      shelf: parse.integer(row['الموقع على الرف']),
      cover: parse.nullable(row['الغلاف']),
      isbn: code.value,
      placeId: placeId ?? null,
      departmentId,
      languages: parse.languages(row['اللغة']),
    };
  });
}

function buildArticles(rows: Row[], bookIds: Set<string>, report: Report) {
  requireColumns(rows, 'articles', [
    'bibID', 'العنوان', 'المؤلفون', 'السنة', 'نوع الوثيقة', 'نوع المصدر', 'عنوان المصدر',
    'ISSN / ISBN', 'الكلمات المفتاحية', 'المجلد', 'العدد', 'الصفحات', 'رابط الوصول المباشر', 'DOI', 'نسبة الارتباط',
  ]);

  const byId = new Map<string, ReturnType<typeof toArticle> & { bookIds: Set<string> }>();

  function toArticle(row: Row, owner: string) {
    const titleText = parse.text(row['العنوان']);
    if (titleText.length === 0) throw new Error(`${owner}: article has no title`);

    const sourceTypeId = lookup(SOURCE_TYPE_BY_SHEET_NAME, parse.text(row['نوع المصدر']), 'source type', owner);
    let typeId = lookup(ARTICLE_TYPE_BY_SHEET_NAME, parse.text(row['نوع الوثيقة']), 'document type', owner);
    if (sourceTypeId === 'conference' && typeId !== 'conference-paper') {
      report.reclassified.push(`${owner} "${parse.text(row['نوع الوثيقة'])}" → conference paper`);
      typeId = 'conference-paper';
    }

    const doi = parse.nullable(row['DOI']);
    const issn = parse.nullable(row['ISSN / ISBN']);
    if (issn === null) report.noIssn += 1;
    const rawScore = parse.text(row['نسبة الارتباط']);
    const score = rawScore.length > 0 && Number.isFinite(Number(rawScore)) ? Number(rawScore) : null;

    return {
      id: articleId(doi, titleText),
      title: titleText,
      authors: parse.nullable(row['المؤلفون']),
      sourceTitle: parse.nullable(row['عنوان المصدر']),
      keywords: parse.nullable(row['الكلمات المفتاحية']),
      doi,
      year: parse.year(row['السنة']),
      issn,
      volume: parse.nullable(row['المجلد']),
      issue: parse.nullable(row['العدد']),
      pages: parse.nullable(row['الصفحات']),
      score,
      url: parse.nullable(row['رابط الوصول المباشر']),
      typeId,
      sourceTypeId,
    };
  }

  rows.forEach((row, i) => {
    const bookId = parse.text(row['bibID']);
    const owner = `Article row ${i + 2}`;
    if (!bookIds.has(bookId)) throw new Error(`${owner} points at BibID ${bookId}, which is not in the books sheet`);

    const article = toArticle(row, owner);
    const existing = byId.get(article.id);
    if (existing) {
      existing.bookIds.add(bookId);
      report.mergedArticles.push(`"${article.title.slice(0, 60)}" → books ${[...existing.bookIds].join(', ')}`);
    } else {
      byId.set(article.id, { ...article, bookIds: new Set([bookId]) });
    }
  });

  return [...byId.values()];
}

// ─── Seed ──────────────────────────────────────────────────

async function main(): Promise<void> {
  console.log(DRY_RUN ? `Dry run — reading ${XLSX_PATH}, nothing will be written` : `Reading ${XLSX_PATH}`);
  const wb = XLSX.readFile(XLSX_PATH);
  const report: Report = {
    editionInferred: [], isbnPadded: [], isbnBad: [], noAuthor: [],
    placeIsBinding: [], mergedArticles: [], reclassified: [], noIssn: 0,
  };

  // Build everything first: a bad cell aborts before a single row is written.
  const books = buildBooks(readSheet(wb, 'books'), report);
  const bookIds = new Set(books.map((b) => b.id));
  const articles = buildArticles(readSheet(wb, 'articles'), bookIds, report);

  const mapNodeIds = readMapNodeIds();
  const departments = DEPARTMENTS.map((d, i) => {
    const node = MAP_NODE_OVERRIDES[d.id] ?? d.id;
    return { ...d, mapNodeId: mapNodeIds.has(node) ? node : null, sortOrder: i };
  });

  // ── Lookups + departments + places ──
  if (!DRY_RUN) {
    for (const d of departments) await prisma.department.upsert({ where: { id: d.id }, create: d, update: d });
    for (const p of PLACES) await prisma.place.upsert({ where: { id: p.id }, create: p, update: p });
    for (const l of LANGUAGES) await prisma.language.upsert({ where: { id: l.id }, create: l, update: l });
    for (const e of EDITION_TYPES) await prisma.editionType.upsert({ where: { id: e.id }, create: e, update: e });
    for (const t of ARTICLE_TYPES) await prisma.articleType.upsert({ where: { id: t.id }, create: t, update: t });
    for (const s of SOURCE_TYPES) await prisma.sourceType.upsert({ where: { id: s.id }, create: s, update: s });
  }
  console.log(
    `  lookups: ${departments.length} departments, ${PLACES.length} places, ${LANGUAGES.length} languages, ` +
      `${EDITION_TYPES.length} edition types, ${ARTICLE_TYPES.length} article types, ${SOURCE_TYPES.length} source types`,
  );
  const unmapped = departments.filter((d) => d.mapNodeId === null);
  if (unmapped.length > 0) {
    console.warn(
      `  ! no map node for: ${unmapped.map((d) => d.id).join(', ')} — ` +
        'navigation to these sections is disabled until library_map.json gains a node with the same id',
    );
  }

  // ── Books ──
  if (!DRY_RUN) {
    for (const { languages, ...b } of books) {
      await prisma.book.upsert({ where: { id: b.id }, create: b, update: b });
    }
    await prisma.book.deleteMany({ where: { id: { notIn: [...bookIds] } } });
    await prisma.bookLanguage.deleteMany({});
    await prisma.bookLanguage.createMany({
      data: books.flatMap((b) => b.languages.map((l) => ({ bookId: b.id, ...l }))),
    });
  }
  const languageLinks = books.reduce((n, b) => n + b.languages.length, 0);
  console.log(`  books: ${books.length} (${languageLinks} language links)`);

  // ── Articles + links ──
  const links = articles.flatMap((a) => [...a.bookIds].map((bookId) => ({ bookId, articleId: a.id })));
  if (!DRY_RUN) {
    for (const { bookIds: _ids, ...a } of articles) {
      await prisma.article.upsert({ where: { id: a.id }, create: a, update: a });
    }
    await prisma.article.deleteMany({ where: { id: { notIn: articles.map((a) => a.id) } } });
    await prisma.bookArticle.deleteMany({});
    await prisma.bookArticle.createMany({ data: links, skipDuplicates: true });
  }
  console.log(`  articles: ${articles.length}`);
  console.log(`  book↔article links: ${links.length}`);

  // ── What the seed had to repair ──
  console.log('\nRepairs (review these in the sheet):');
  const list = (label: string, items: string[]) => {
    if (items.length > 0) console.log(`  ${label} (${items.length}):\n${items.map((i) => `      ${i}`).join('\n')}`);
  };
  list('editions supplied by the cataloguer ([ ] in the sheet)', report.editionInferred);
  list('ISBNs that lost a leading zero in Excel — restored', report.isbnPadded);
  list('ISBNs that fail their checksum — kept as typed', report.isbnBad);
  list('books with no author on record', report.noAuthor);
  list('"place" cells that are really a binding (Hardcover/Paperback)', report.placeIsBinding);
  list('articles listed under several books — merged', report.mergedArticles);
  list('documents re-typed as conference papers (source is a conference)', report.reclassified);
  if (report.noIssn > 0) console.log(`  ${report.noIssn} article rows have no ISSN/ISBN`);

  console.log(DRY_RUN ? '\nDry run complete — the sheet is valid, no rows written.' : '\nSeed complete.');
}

main()
  .catch((err) => {
    console.error('Seed failed:', err instanceof Error ? err.message : err);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
