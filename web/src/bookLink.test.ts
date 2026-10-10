import { describe, expect, it } from 'vitest';
import { bookPath, parseBibid, slugify } from './bookLink';

describe('parseBibid', () => {
  it('reads the id after the last hyphen', () => {
    expect(parseBibid('/dalili/construction-detailing-for-landscape-12554857')).toBe('12554857');
  });

  it('accepts a bare id', () => {
    expect(parseBibid('/dalili/12554857')).toBe('12554857');
  });

  it('is not fooled by digits inside the name', () => {
    // "2nd" and "1990" are part of the title, not the key.
    expect(parseBibid('/dalili/design-manual-2nd-edition-1990-267302')).toBe('267302');
  });

  it('reads an Arabic name and an encoded one the same way', () => {
    expect(parseBibid('/dalili/العمارة-كتلة-وفراغ-12631333')).toBe('12631333');
    expect(parseBibid('/dalili/' + encodeURIComponent('العمارة-كتلة-وفراغ-12631333'))).toBe('12631333');
  });

  it('tolerates a trailing slash', () => {
    expect(parseBibid('/dalili/x-12554857/')).toBe('12554857');
  });

  it('rejects anything that is not a book link', () => {
    expect(parseBibid('/')).toBeNull();
    expect(parseBibid('/dalili')).toBeNull();
    expect(parseBibid('/dalili/')).toBeNull();
    expect(parseBibid('/other/x-123')).toBeNull();
    expect(parseBibid('/dalili/a/b-123')).toBeNull();
    expect(parseBibid('/dalili/title-')).toBeNull();
  });
});

describe('slugify', () => {
  it('lowercases and hyphenates', () => {
    expect(slugify('Construction detailing for landscape and garden design')).toBe(
      'construction-detailing-for-landscape-and-garden-design',
    );
  });

  it('drops punctuation', () => {
    expect(slugify('Electric machines :')).toBe('electric-machines');
    expect(slugify('GATE Electrical engineering : (2nd ed.)')).toBe('gate-electrical-engineering-2nd-ed');
  });

  it('keeps Arabic letters', () => {
    expect(slugify('العمارة كتلة وفراغ ونظام')).toBe('العمارة-كتلة-وفراغ-ونظام');
  });

  it('never returns an empty slug', () => {
    expect(slugify('::: ---')).toBe('book');
    expect(slugify('')).toBe('book');
  });

  it('cuts a long title on a word boundary', () => {
    const slug = slugify('Digital signal processing system analysis and design with applications');
    expect(slug.length).toBeLessThanOrEqual(60);
    expect(slug.endsWith('-')).toBe(false);
    expect('digital-signal-processing-system-analysis-and-design-with-applications').toContain(slug);
  });
});

describe('bookPath', () => {
  it('round-trips through parseBibid', () => {
    const path = bookPath('Concrete technology: Theory and Practice', '40959');
    expect(path).toBe('/dalili/concrete-technology-theory-and-practice-40959');
    expect(parseBibid(path)).toBe('40959');
  });

  it('round-trips even when the title ends in digits', () => {
    expect(parseBibid(bookPath('Calculus 2011', '13134446'))).toBe('13134446');
  });
});
