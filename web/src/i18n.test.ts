import { describe, expect, it } from 'vitest';
import { detectLang, t } from './i18n';

describe('detectLang', () => {
  it('honours an explicit ?lang', () => {
    expect(detectLang('?lang=en', 'ar-EG')).toBe('en');
    expect(detectLang('?lang=ar', 'en-US')).toBe('ar');
  });

  it('falls back to the browser language', () => {
    expect(detectLang('', 'ar-EG')).toBe('ar');
    expect(detectLang('', 'en-GB')).toBe('en');
    expect(detectLang('?lang=fr', 'fr-FR')).toBe('en');
  });
});

describe('strings', () => {
  it('has the same keys in both languages', () => {
    expect(Object.keys(t('en')).sort()).toEqual(Object.keys(t('ar')).sort());
  });
});
