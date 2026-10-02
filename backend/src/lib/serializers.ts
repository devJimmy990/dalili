import type {
  Prisma,
  Article,
  ArticleType,
  Book,
  BookLanguage,
  Department,
  EditionType,
  Language,
  Place,
  SourceType,
} from '@prisma/client';
import type { Lang } from './lang.js';
import { editionLabel, languageLabel, locationLabel, pick, shelfLabel, unknownAuthor } from './lang.js';

// Shapes the client sees. Names are camelCase and locale-resolved:
// a book carries one `department.name`, not `nameAr` + `nameEn`.

export type ArticleRow = Article & {
  type: ArticleType | null;
  sourceType: SourceType | null;
};

export type BookRow = Book & {
  department: Department;
  place: Place | null;
  editionType: EditionType | null;
  languages: (BookLanguage & { language: Language })[];
  articles: { article: ArticleRow }[];
};

export function serializeDepartment(d: Department, lang: Lang) {
  return {
    id: d.id,
    name: pick(d, lang),
    mapNodeId: d.mapNodeId,
  };
}

export function serializePlace(p: Place | null, lang: Lang) {
  if (!p) return null;
  return { id: p.id, name: pick(p, lang) };
}

/// `type` and `source` stay flat strings (the localized name) so existing
/// clients keep working; `typeId` / `sourceTypeId` are the stable ids for
/// anything that wants to filter or style by kind.
export function serializeArticle(a: ArticleRow, lang: Lang, bookIds: string[] = []) {
  return {
    id: a.id,
    bookIds,
    title: a.title,
    authors: a.authors,
    year: a.year,
    typeId: a.typeId,
    type: a.type ? pick(a.type, lang) : null,
    sourceTypeId: a.sourceTypeId,
    source: a.sourceType ? pick(a.sourceType, lang) : null,
    sourceTitle: a.sourceTitle,
    issn: a.issn,
    keywords: a.keywords,
    volume: a.volume,
    issue: a.issue,
    pages: a.pages,
    url: a.url,
    doi: a.doi,
    score: a.score,
  };
}

export function serializeBook(b: BookRow, lang: Lang) {
  const department = serializeDepartment(b.department, lang);
  // Nulls are passed through as nulls, never coerced to "" — the client
  // decides whether to hide the row or show a placeholder.

  return {
    id: b.id,
    callNumber: b.callNumber,
    title: b.title,
    author: b.author ?? unknownAuthor(lang),
    edition: b.editionNumber,
    editionLabel: editionLabel(b.editionNumber, b.editionType, lang),
    editionType: b.editionType ? { id: b.editionType.id, name: pick(b.editionType, lang) } : null,
    /// Printed in brackets in the catalogue: the cataloguer's inference.
    editionInferred: b.editionInferred,
    publisher: b.publisher,
    place: serializePlace(b.place, lang),
    year: b.year,
    subjects: b.subjects,
    shelf: b.shelf,
    shelfLabel: shelfLabel(b.shelf, lang),
    department,
    // Physical location is the department's spot on the library map,
    // so the app can hand `nodeId` straight to the navigation engine.
    location: {
      nodeId: b.department.mapNodeId,
      name: department.name,
    },
    /// "قسم كهرباء، الرف 31" — ready to print.
    locationLabel: locationLabel(department.name, b.shelf, lang),
    /// Display text ("Arabic (translated from English)").
    language: languageLabel(b.languages, lang),
    languages: b.languages.map((l) => ({ id: l.languageId, name: pick(l.language, lang), role: l.role })),
    cover: b.cover,
    isbn: b.isbn,
    articles: b.articles.map(({ article }) => serializeArticle(article, lang)),
  };
}

/// Relations every book response needs.
export const bookInclude = {
  department: true,
  place: true,
  editionType: true,
  languages: { include: { language: true }, orderBy: [{ role: 'asc' }, { position: 'asc' }] },
  articles: {
    include: { article: { include: { type: true, sourceType: true } } },
    // Best match first, the same order the related-articles screen uses.
    orderBy: [{ article: { score: 'desc' } }, { articleId: 'asc' }],
  },
} satisfies Prisma.BookInclude;
