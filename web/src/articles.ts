import type { Article } from './api';
import type { Lang } from './i18n';

/**
 * Only http(s) is ever put in an href. Article links come from a spreadsheet
 * people edit by hand, so a `javascript:` or `data:` value must never become a
 * clickable link — it would run in this page's origin.
 */
export function safeHref(raw: string | null | undefined): string | null {
  if (!raw) return null;
  try {
    const url = new URL(raw.trim());
    return url.protocol === 'https:' || url.protocol === 'http:' ? url.href : null;
  } catch {
    return null;
  }
}

/** The DOI as a resolvable link, or null when it is blank or malformed. */
export function doiHref(doi: string | null | undefined): string | null {
  const clean = (doi ?? '').trim().replace(/^https?:\/\/(dx\.)?doi\.org\//i, '');
  // Every DOI starts "10.<registrant>/<suffix>"; anything else is not one.
  if (!/^10\.\d{4,9}\/\S+$/.test(clean)) return null;
  return `https://doi.org/${clean.split('/').map(encodeURIComponent).join('/')}`;
}

/**
 * Where an article opens: its own link, otherwise its DOI. Null when it has
 * neither, in which case the title is shown as plain text.
 */
export function articleHref(article: Pick<Article, 'url' | 'doi'>): string | null {
  return safeHref(article.url) ?? doiHref(article.doi);
}

/** Best match first; articles nobody scored go last, in a stable order. */
export function sortArticles(articles: readonly Article[]): Article[] {
  return articles
    .map((article, index) => ({ article, index }))
    .sort((a, b) => {
      const sa = a.article.score ?? -1;
      const sb = b.article.score ?? -1;
      return sb - sa || a.index - b.index;
    })
    .map(({ article }) => article);
}

/** 0.95 → "95%". Null when the article was never scored. */
export function relevanceLabel(score: number | null): string | null {
  if (score === null || !Number.isFinite(score)) return null;
  return `${Math.round(Math.min(Math.max(score, 0), 1) * 100)}%`;
}

const LABELS = {
  ar: { volume: 'المجلد', issue: 'العدد', pages: 'ص' },
  en: { volume: 'Vol.', issue: 'No.', pages: 'pp.' },
} as const;

/** "Sustainability · 2022" — the line under the authors. */
export function sourceLine(article: Pick<Article, 'sourceTitle' | 'year'>): string | null {
  const parts = [article.sourceTitle, article.year].filter(
    (part): part is string | number => part !== null && part !== '',
  );
  return parts.length > 0 ? parts.join(' · ') : null;
}

/** "Vol. 14, No. 2, pp. 991" — only the parts the record has. */
export function citationLine(
  article: Pick<Article, 'volume' | 'issue' | 'pages'>,
  lang: Lang,
): string | null {
  const l = LABELS[lang];
  const parts = [
    article.volume ? `${l.volume} ${article.volume}` : null,
    article.issue ? `${l.issue} ${article.issue}` : null,
    article.pages ? `${l.pages} ${article.pages}` : null,
  ].filter((part): part is string => part !== null);

  return parts.length > 0 ? parts.join(lang === 'ar' ? '، ' : ', ') : null;
}
