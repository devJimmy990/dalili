import { prisma } from '../lib/prisma.js';
import type { Lang } from '../lib/lang.js';
import { serializeArticle } from '../lib/serializers.js';

/// Articles are always reached through their book — the app has no
/// standalone article catalogue, only a "related articles" screen.
/// Ranked by the dataset's own relevance score.
export async function getArticlesForBook(bookId: string, lang: Lang) {
  const rows = await prisma.article.findMany({
    where: { books: { some: { bookId } } },
    include: { type: true, sourceType: true, books: { select: { bookId: true } } },
    orderBy: [{ score: 'desc' }, { id: 'asc' }],
  });
  return rows.map((a) => serializeArticle(a, lang, a.books.map((b) => b.bookId)));
}
