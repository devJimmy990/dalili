import type { Prisma } from '@prisma/client';
import { prisma } from '../lib/prisma.js';
import { bookInclude, serializeBook } from '../lib/serializers.js';
import type { Lang } from '../lib/lang.js';

export interface Page {
  page: number;
  limit: number;
}

export interface Paginated<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasMore: boolean;
}

/// Books sort by title so pagination is stable across requests
/// (Postgres gives no order guarantee otherwise).
const ORDER: Prisma.BookOrderByWithRelationInput[] = [{ title: 'asc' }, { id: 'asc' }];

async function paginate(
  where: Prisma.BookWhereInput,
  { page, limit }: Page,
  lang: Lang,
): Promise<Paginated<ReturnType<typeof serializeBook>>> {
  const [total, rows] = await prisma.$transaction([
    prisma.book.count({ where }),
    prisma.book.findMany({
      where,
      include: bookInclude,
      orderBy: ORDER,
      skip: (page - 1) * limit,
      take: limit,
    }),
  ]);

  return {
    items: rows.map((b) => serializeBook(b, lang)),
    total,
    page,
    limit,
    totalPages: Math.max(1, Math.ceil(total / limit)),
    hasMore: page * limit < total,
  };
}

export function listBooks(page: Page, lang: Lang, filters: { departmentId?: string; author?: string } = {}) {
  const where: Prisma.BookWhereInput = {};
  if (filters.departmentId) where.departmentId = filters.departmentId;
  if (filters.author) where.author = { contains: filters.author, mode: 'insensitive' };
  return paginate(where, page, lang);
}

/// Matches the book's own fields, and also books whose linked articles
/// match — the dataset hides a lot of subject matter in article keywords.
///
/// Returns every hit in one response: the catalogue is small enough that
/// paging the search would cost a round trip for nothing.
export async function searchBooks(query: string, lang: Lang) {
  const q = query.trim();
  const where: Prisma.BookWhereInput = {
    OR: [
      { title: { contains: q, mode: 'insensitive' } },
      { author: { contains: q, mode: 'insensitive' } },
      { subjects: { contains: q, mode: 'insensitive' } },
      { publisher: { contains: q, mode: 'insensitive' } },
      { callNumber: { contains: q, mode: 'insensitive' } },
      {
        articles: {
          some: {
            article: {
              OR: [
                { title: { contains: q, mode: 'insensitive' } },
                { keywords: { contains: q, mode: 'insensitive' } },
              ],
            },
          },
        },
      },
    ],
  };

  const rows = await prisma.book.findMany({ where, include: bookInclude, orderBy: ORDER });
  return { items: rows.map((b) => serializeBook(b, lang)), total: rows.length };
}

export async function getBookById(id: string, lang: Lang) {
  const row = await prisma.book.findUnique({ where: { id }, include: bookInclude });
  return row ? serializeBook(row, lang) : null;
}

/// Used by the favorites screen to refresh cached books after a
/// language switch. Requested order is preserved.
export async function getBooksByIds(ids: string[], lang: Lang) {
  if (ids.length === 0) return [];
  const rows = await prisma.book.findMany({ where: { id: { in: ids } }, include: bookInclude });
  const byId = new Map(rows.map((r) => [r.id, r]));
  return ids.flatMap((id) => {
    const row = byId.get(id);
    return row ? [serializeBook(row, lang)] : [];
  });
}
