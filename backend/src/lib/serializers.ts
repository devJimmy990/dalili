import type { Article, Book, Department, Place } from '@prisma/client';
import type { Lang } from './lang.js';
import { editionLabel, shelfLabel } from './lang.js';

// Shapes the client sees. Names are camelCase and locale-resolved:
// a book carries one `department.name`, not `nameAr` + `nameEn`.

export type BookRow = Book & {
  department: Department;
  place: Place | null;
  articles: { article: Article }[];
};

export function serializeDepartment(d: Department, lang: Lang) {
  return {
    id: d.id,
    name: lang === 'en' ? d.nameEn : d.nameAr,
    mapNodeId: d.mapNodeId,
  };
}

export function serializePlace(p: Place | null, lang: Lang) {
  if (!p) return null;
  return { id: p.id, name: lang === 'en' ? p.nameEn : p.nameAr };
}

export function serializeArticle(a: Article, bookIds: string[] = []) {
  return {
    id: a.id,
    bookIds,
    title: a.title,
    authors: a.authors,
    year: a.year,
    type: a.type,
    source: a.source,
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
    author: b.author,
    edition: b.edition,
    editionLabel: editionLabel(b.edition, b.editionLabel, lang),
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
    language: b.language,
    cover: b.cover,
    isbn: b.isbn,
    articles: b.articles.map(({ article }) => serializeArticle(article)),
  };
}

/// Relations every book response needs.
export const bookInclude = {
  department: true,
  place: true,
  articles: { include: { article: true }, orderBy: { articleId: 'asc' } },
} as const;
