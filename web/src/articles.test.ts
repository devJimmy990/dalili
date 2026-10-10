import { describe, expect, it } from 'vitest';
import type { Article } from './api';
import { articleHref, citationLine, doiHref, relevanceLabel, safeHref, sortArticles, sourceLine } from './articles';
import { DESKTOP_MIN, TABLET_MIN, isModal, layoutFor } from './layout';

const article = (over: Partial<Article> = {}): Article => ({
  id: 'a',
  title: 'T',
  authors: null,
  year: null,
  type: null,
  source: null,
  sourceTitle: null,
  volume: null,
  issue: null,
  pages: null,
  url: null,
  doi: null,
  score: null,
  ...over,
});

describe('safeHref', () => {
  it('accepts http and https', () => {
    expect(safeHref('https://www.mdpi.com/2071-1050/14/2/991')).toBe('https://www.mdpi.com/2071-1050/14/2/991');
    expect(safeHref('http://example.org/a')).toBe('http://example.org/a');
  });

  it('refuses anything that could run code or is not a web link', () => {
    expect(safeHref('javascript:alert(1)')).toBeNull();
    expect(safeHref('JaVaScRiPt:alert(1)')).toBeNull();
    expect(safeHref('data:text/html,<script>1</script>')).toBeNull();
    expect(safeHref('file:///etc/passwd')).toBeNull();
    expect(safeHref('mailto:a@b.c')).toBeNull();
  });

  it('refuses blanks and garbage', () => {
    expect(safeHref(null)).toBeNull();
    expect(safeHref('')).toBeNull();
    expect(safeHref('   ')).toBeNull();
    expect(safeHref('not a url')).toBeNull();
  });
});

describe('doiHref', () => {
  it('turns a bare DOI into a resolver link', () => {
    expect(doiHref('10.3390/su14020991')).toBe('https://doi.org/10.3390/su14020991');
  });

  it('does not double the resolver when the sheet already has it', () => {
    expect(doiHref('https://doi.org/10.3390/su14020991')).toBe('https://doi.org/10.3390/su14020991');
    expect(doiHref('http://dx.doi.org/10.3390/su14020991')).toBe('https://doi.org/10.3390/su14020991');
  });

  it('keeps the slashes of the suffix but encodes anything unsafe', () => {
    expect(doiHref('10.1002/(SICI)1097-0258(19980815/30)17:15/16<1661::AID-SIM968>3.0.CO;2-2')).toContain(
      '10.1002/',
    );
    expect(doiHref('10.1000/a b')).toBeNull(); // whitespace means it is not a DOI
  });

  it('refuses things that are not DOIs', () => {
    expect(doiHref(null)).toBeNull();
    expect(doiHref('')).toBeNull();
    expect(doiHref('12345')).toBeNull();
    expect(doiHref('javascript:alert(1)')).toBeNull();
  });
});

describe('articleHref', () => {
  it('prefers the article’s own link', () => {
    expect(articleHref({ url: 'https://x.org/p', doi: '10.1000/abc' })).toBe('https://x.org/p');
  });

  it('falls back to the DOI when the link is missing or unsafe', () => {
    expect(articleHref({ url: null, doi: '10.1000/abc' })).toBe('https://doi.org/10.1000/abc');
    expect(articleHref({ url: 'javascript:alert(1)', doi: '10.1000/abc' })).toBe('https://doi.org/10.1000/abc');
  });

  it('is null when there is nothing safe to open', () => {
    expect(articleHref({ url: null, doi: null })).toBeNull();
    expect(articleHref({ url: 'javascript:alert(1)', doi: null })).toBeNull();
  });
});

describe('sortArticles', () => {
  it('puts the best match first and unscored articles last', () => {
    const sorted = sortArticles([
      article({ id: 'none', score: null }),
      article({ id: 'low', score: 0.8 }),
      article({ id: 'high', score: 0.99 }),
      article({ id: 'zero', score: 0 }),
    ]);
    expect(sorted.map((a) => a.id)).toEqual(['high', 'low', 'zero', 'none']);
  });

  it('keeps the catalogue order between equal scores', () => {
    const sorted = sortArticles([
      article({ id: 'a', score: 0.9 }),
      article({ id: 'b', score: 0.9 }),
      article({ id: 'c', score: 0.9 }),
    ]);
    expect(sorted.map((a) => a.id)).toEqual(['a', 'b', 'c']);
  });

  it('does not change the list it was given', () => {
    const input = [article({ id: 'x', score: 0.1 }), article({ id: 'y', score: 0.9 })];
    sortArticles(input);
    expect(input.map((a) => a.id)).toEqual(['x', 'y']);
  });
});

describe('labels', () => {
  it('shows relevance as a whole percent', () => {
    expect(relevanceLabel(0.95)).toBe('95%');
    expect(relevanceLabel(1)).toBe('100%');
    expect(relevanceLabel(0.004)).toBe('0%');
    expect(relevanceLabel(null)).toBeNull();
    expect(relevanceLabel(Number.NaN)).toBeNull();
    expect(relevanceLabel(7)).toBe('100%'); // a bad value cannot exceed the scale
  });

  it('joins source and year, skipping what is absent', () => {
    expect(sourceLine({ sourceTitle: 'Sustainability', year: 2022 })).toBe('Sustainability · 2022');
    expect(sourceLine({ sourceTitle: null, year: 2022 })).toBe('2022');
    expect(sourceLine({ sourceTitle: 'Sustainability', year: null })).toBe('Sustainability');
    expect(sourceLine({ sourceTitle: null, year: null })).toBeNull();
  });

  it('writes the citation in the reader’s language', () => {
    const a = { volume: '14', issue: '2', pages: '991' };
    expect(citationLine(a, 'en')).toBe('Vol. 14, No. 2, pp. 991');
    expect(citationLine(a, 'ar')).toBe('المجلد 14، العدد 2، ص 991');
    expect(citationLine({ volume: '14', issue: null, pages: null }, 'en')).toBe('Vol. 14');
    expect(citationLine({ volume: null, issue: null, pages: null }, 'en')).toBeNull();
  });
});

describe('layoutFor', () => {
  it('chooses the presentation by width', () => {
    expect(layoutFor(375)).toBe('sheet');
    expect(layoutFor(TABLET_MIN - 1)).toBe('sheet');
    expect(layoutFor(TABLET_MIN)).toBe('drawer');
    expect(layoutFor(820)).toBe('drawer');
    expect(layoutFor(DESKTOP_MIN - 1)).toBe('drawer');
    expect(layoutFor(DESKTOP_MIN)).toBe('panel');
    expect(layoutFor(1920)).toBe('panel');
  });

  it('only the desktop column is part of the page; the others are modal', () => {
    expect(isModal('panel')).toBe(false);
    expect(isModal('drawer')).toBe(true);
    expect(isModal('sheet')).toBe(true);
  });
});
