import { API_BASE_URL } from './env';
import type { Lang } from './i18n';

export interface Book {
  id: string;
  title: string;
  author: string;
  callNumber: string;
  isbn: string | null;
  publisher: string | null;
  year: number | null;
  editionLabel: string | null;
  language: string | null;
  cover: string | null;
  place: { id: string; name: string } | null;
  locationLabel: string;
  shelfLabel: string | null;
  department: { id: string; name: string };
}

export type BookResult =
  | { kind: 'found'; book: Book }
  | { kind: 'missing' }
  | { kind: 'error'; message: string };

/**
 * Loads a book by BibID. A free Render service sleeps when idle and takes
 * up to a minute to wake, so the first request is allowed to be slow and a
 * failed one is retried before the visitor is shown an error.
 */
export async function fetchBook(bibid: string, lang: Lang, signal?: AbortSignal): Promise<BookResult> {
  const url = `${API_BASE_URL}/books/${encodeURIComponent(bibid)}?lang=${lang}`;

  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const response = await fetch(url, { signal });
      const body = (await response.json().catch(() => null)) as
        | { status?: string; data?: { book?: Book }; code?: string; message?: string }
        | null;

      // Only an explicit book_not_found means the book is missing. Any other
      // 404 is the server being too old or the wrong one, which is not the
      // same thing and must not be reported as a missing book.
      if (response.status === 404 && body?.code === 'book_not_found') return { kind: 'missing' };
      if (response.ok && body?.data?.book) return { kind: 'found', book: body.data.book };

      throw new Error(body?.message ?? `HTTP ${response.status}`);
    } catch (error) {
      if (signal?.aborted) return { kind: 'error', message: 'aborted' };
      if (attempt === 2) {
        return { kind: 'error', message: error instanceof Error ? error.message : String(error) };
      }
      await new Promise((resolve) => setTimeout(resolve, 1500 * (attempt + 1)));
    }
  }
  return { kind: 'error', message: 'unreachable' };
}
