/**
 * The shape of a shared book link. The mobile app builds these and reads them
 * back (mobile/lib/core/utils/book_link.dart) — the two must agree, and both
 * are tested against the same examples.
 *
 *   https://<host>/dalili/<book-name>-<bibid>
 *
 * The name is only there to be readable in a chat. The BibID after the last
 * hyphen is the key: names repeat and change, a BibID does not.
 */

export const LINK_PREFIX = 'dalili';

/**
 * The BibID in a pathname such as `/dalili/construction-detailing-12554857`,
 * or null when the path is not a book link.
 */
export function parseBibid(pathname: string): string | null {
  const parts = pathname.split('/').filter((part) => part.length > 0);
  if (parts.length !== 2 || parts[0] !== LINK_PREFIX) return null;

  let segment = parts[1]!;
  try {
    segment = decodeURIComponent(segment);
  } catch {
    // A stray "%" — use the text as it came rather than reject the link.
  }

  // Everything after the last hyphen. A bare "/dalili/12554857" has no hyphen,
  // so the whole segment is the id.
  const id = segment.slice(segment.lastIndexOf('-') + 1).trim();
  return id.length > 0 ? id : null;
}

/** A readable, URL-safe form of a title. Keeps letters of any script. */
export function slugify(title: string, maxLength = 60): string {
  const slug = title
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, '-')
    .replace(/^-+|-+$/g, '');

  if (slug.length === 0) return 'book';
  if (slug.length <= maxLength) return slug;

  // Cut on a word boundary so the link never ends mid-word.
  const cut = slug.slice(0, maxLength);
  const lastHyphen = cut.lastIndexOf('-');
  return (lastHyphen > 10 ? cut.slice(0, lastHyphen) : cut).replace(/-+$/g, '');
}

export function bookPath(title: string, bibid: string): string {
  return `/${LINK_PREFIX}/${slugify(title)}-${bibid}`;
}
