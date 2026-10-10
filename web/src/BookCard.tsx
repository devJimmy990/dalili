import { ANDROID_PACKAGE, APP_DOWNLOAD_URL } from './env';
import type { Book } from './api';
import { t, type Lang } from './i18n';

/**
 * An Android intent URL: opens the app if it is installed, and falls back to
 * this same page if not. A normal link already opens the app when the domain
 * is verified; this is the explicit button for browsers that don't.
 */
function intentUrl(): string {
  const { host, pathname, search } = window.location;
  const fallback = encodeURIComponent(window.location.href);
  return `intent://${host}${pathname}${search}#Intent;scheme=https;package=${ANDROID_PACKAGE};S.browser_fallback_url=${fallback};end`;
}

export function BookCard({ book, lang }: { book: Book; lang: Lang }) {
  const strings = t(lang);

  const rows: [string, string | number | null, boolean?][] = [
    [strings.callNumber, book.callNumber, true],
    [strings.bibid, book.id, true],
    [strings.isbn, book.isbn, true],
    [strings.publisher, book.publisher],
    [strings.place, book.place?.name ?? null],
    [strings.year, book.year],
    [strings.edition, book.editionLabel],
    [strings.language, book.language],
  ];

  return (
    <article className="book">
      <div className="book__top">
        {book.cover ? (
          <img className="book__cover" src={book.cover} alt="" width={120} height={170} loading="eager" />
        ) : (
          <div className="book__cover book__cover--empty" aria-hidden="true" />
        )}
        <div className="book__heading">
          <h1>{book.title}</h1>
          <p className="book__author">{book.author}</p>
        </div>
      </div>

      <div className="location">
        <span className="location__label">{strings.location}</span>
        <strong className="location__value">{book.locationLabel}</strong>
      </div>

      <dl className="facts">
        {rows
          .filter(([, value]) => value !== null && value !== '')
          .map(([label, value, code]) => (
            <div className="facts__row" key={label}>
              <dt>{label}</dt>
              <dd className={code ? 'code' : undefined}>{value}</dd>
            </div>
          ))}
      </dl>

      <div className="actions">
        <a className="button button--primary" href={intentUrl()}>
          {strings.openInApp}
        </a>
        {APP_DOWNLOAD_URL && (
          <a className="button button--ghost" href={APP_DOWNLOAD_URL} rel="noopener">
            {strings.getApp}
          </a>
        )}
      </div>
      <p className="hint">{strings.appHint}</p>
    </article>
  );
}
