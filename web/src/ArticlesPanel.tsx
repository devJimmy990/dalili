import { useEffect, useId, useMemo, useRef, type KeyboardEvent } from 'react';
import type { Article } from './api';
import { articleHref, citationLine, doiHref, relevanceLabel, sortArticles, sourceLine } from './articles';
import { t, type Lang } from './i18n';
import { isModal, type LayoutMode } from './layout';

const FOCUSABLE = 'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])';

interface Props {
  articles: readonly Article[];
  lang: Lang;
  mode: LayoutMode;
  onClose: () => void;
}

/**
 * The related articles of a book, in whichever form the screen suits: a
 * column beside the book (desktop), a drawer (tablet) or a bottom sheet
 * (phone). The list inside is the same; only the frame around it changes.
 */
export function ArticlesPanel({ articles, lang, mode, onClose }: Props) {
  const strings = t(lang);
  const headingId = useId();
  const frame = useRef<HTMLElement>(null);
  const closeButton = useRef<HTMLButtonElement>(null);
  const modal = isModal(mode);
  const sorted = useMemo(() => sortArticles(articles), [articles]);

  // Move focus in when it opens, and back to whatever opened it when it
  // closes — otherwise a keyboard user is left stranded at the top of the page.
  useEffect(() => {
    const opener = document.activeElement as HTMLElement | null;
    closeButton.current?.focus();
    return () => opener?.focus?.();
  }, []);

  // A drawer and a sheet sit over the page; the page must not scroll beneath.
  useEffect(() => {
    if (!modal) return;
    const { overflow } = document.body.style;
    document.body.style.overflow = 'hidden';
    return () => {
      document.body.style.overflow = overflow;
    };
  }, [modal]);

  const onKeyDown = (event: KeyboardEvent) => {
    if (event.key === 'Escape') {
      event.stopPropagation();
      onClose();
      return;
    }
    // Keep Tab inside a modal frame. The page behind it is not reachable.
    if (event.key === 'Tab' && modal && frame.current) {
      const items = [...frame.current.querySelectorAll<HTMLElement>(FOCUSABLE)];
      const first = items[0];
      const last = items[items.length - 1];
      if (!first || !last) return;
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  };

  const content = (
    <aside
      ref={frame}
      className={`articles articles--${mode}`}
      aria-labelledby={headingId}
      role={modal ? 'dialog' : 'complementary'}
      aria-modal={modal || undefined}
      onKeyDown={onKeyDown}
    >
      {mode === 'sheet' && <span className="articles__grabber" aria-hidden="true" />}

      <header className="articles__header">
        <h2 id={headingId}>
          {strings.relatedArticles}
          <span className="articles__count">{sorted.length}</span>
        </h2>
        <button
          ref={closeButton}
          type="button"
          className="articles__close"
          onClick={onClose}
          aria-label={strings.closeArticles}
        >
          <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true">
            <path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
          </svg>
        </button>
      </header>

      <ul className="articles__list">
        {sorted.map((article) => (
          <ArticleItem key={article.id} article={article} lang={lang} />
        ))}
      </ul>
    </aside>
  );

  if (!modal) return content;

  return (
    <div className="scrim" onMouseDown={(event) => event.target === event.currentTarget && onClose()}>
      {content}
    </div>
  );
}

function ArticleItem({ article, lang }: { article: Article; lang: Lang }) {
  const strings = t(lang);
  const href = articleHref(article);
  const doi = doiHref(article.doi);
  const relevance = relevanceLabel(article.score);
  const source = sourceLine(article);
  const citation = citationLine(article, lang);
  const kind = [article.type, article.source].filter(Boolean).join(' · ');

  return (
    <li className="article">
      <h3 className="article__title" lang="en" dir="auto">
        {href ? (
          // A new tab, so the book stays open behind it. noopener/noreferrer:
          // the article's site gets no handle on this page and no referrer.
          <a href={href} target="_blank" rel="noopener noreferrer" aria-label={`${article.title} — ${strings.opensInNewTab}`}>
            {article.title}
            <svg className="article__external" viewBox="0 0 24 24" width="14" height="14" aria-hidden="true">
              <path
                d="M14 4h6v6M20 4l-9 9M18 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </a>
        ) : (
          article.title
        )}
      </h3>

      {article.authors && (
        <p className="article__authors" dir="auto">
          {article.authors}
        </p>
      )}
      {source && (
        <p className="article__meta" dir="auto">
          {source}
        </p>
      )}
      {citation && <p className="article__meta">{citation}</p>}

      <div className="article__tags">
        {kind && <span className="chip">{kind}</span>}
        {relevance && (
          <span className="chip chip--accent" title={strings.relevance}>
            {relevance}
          </span>
        )}
        {doi && (
          <a className="chip chip--link" href={doi} target="_blank" rel="noopener noreferrer" dir="ltr">
            {strings.doi}
          </a>
        )}
      </div>
    </li>
  );
}
