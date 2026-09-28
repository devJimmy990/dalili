import { prisma } from '../lib/prisma.js';
import { serializeArticle } from '../lib/serializers.js';

/// Articles are always reached through their book — the app has no
/// standalone article catalogue, only a "related articles" screen.
/// Ranked by the dataset's own relevance score.
export async function getArticlesForBook(bookId: string) {
  const rows = await prisma.article.findMany({
    where: { books: { some: { bookId } } },
    include: { books: { select: { bookId: true } } },
    orderBy: [{ score: 'desc' }, { id: 'asc' }],
  });
  return rows.map((a) => serializeArticle(a, a.books.map((b) => b.bookId)));
}
