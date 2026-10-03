import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ARTICLE_TYPE_BY_SHEET_NAME, ARTICLE_TYPES, PLACE_BY_SHEET_NAME } from './lookups.js';
import { PLACES } from './reference-data.js';
import { editionLabel } from '../src/lib/lang.js';
import * as p from './sheet-parsers.js';

test('edition: every spelling in the sheet', () => {
  assert.deepEqual(p.edition('2nd. ed'), { number: 2, typeId: 'standard', inferred: false });
  assert.deepEqual(p.edition('[1st. ed]'), { number: 1, typeId: 'standard', inferred: true });
  assert.deepEqual(p.edition('[2st. ed]'), { number: 2, typeId: 'standard', inferred: true });
  assert.deepEqual(p.edition('ط. 1'), { number: 1, typeId: 'standard', inferred: false });
  assert.deepEqual(p.edition('[د.ط]'), { number: null, typeId: 'unspecified', inferred: true });
  assert.deepEqual(p.edition('International edition.'), { number: null, typeId: 'international', inferred: false });
  assert.deepEqual(p.edition('Teacher ed.'), { number: null, typeId: 'teacher', inferred: false });
  assert.throws(() => p.edition('Revised pocket printing'), /Unrecognised edition/);
});

test('edition label: brackets in the sheet are shown, none are invented', () => {
  const std = { id: 'standard', nameAr: 'طبعة عادية', nameEn: 'Standard edition' };
  assert.equal(editionLabel(1, std, 'en', false), '1st');
  assert.equal(editionLabel(1, std, 'en', true), '[1st]');
  assert.equal(editionLabel(1, std, 'ar', true), '[ط. 1]');
  const none = { id: 'unspecified', nameAr: 'غير محددة', nameEn: 'Not specified' };
  assert.equal(editionLabel(null, none, 'ar', true), null);
});

test('isbn: restores the zero Excel dropped, but only when the checksum agrees', () => {
  assert.deepEqual(p.isbn(521781752), { value: '0521781752', note: 'padded' });
  assert.deepEqual(p.isbn('033377776X'), { value: '033377776X' });
  assert.deepEqual(p.isbn(' 9780123746467'), { value: '9780123746467' });
  assert.equal(p.isbn('9789772873133').note, 'bad-checksum');
  assert.equal(p.isbn('').value, null);
});

test('languages: translated and bilingual books', () => {
  assert.deepEqual(p.languages('الإنجليزية'), [{ languageId: 'en', role: 'TEXT', position: 0 }]);
  assert.deepEqual(p.languages('العربية (مترجم عن الإنجليزية)'), [
    { languageId: 'ar', role: 'TEXT', position: 0 },
    { languageId: 'en', role: 'TRANSLATED_FROM', position: 1 },
  ]);
  assert.deepEqual(p.languages('الكورية والإنجليزية'), [
    { languageId: 'ko', role: 'TEXT', position: 0 },
    { languageId: 'en', role: 'TEXT', position: 1 },
  ]);
  assert.throws(() => p.languages('الفرنسية'), /Unrecognised language/);
});

test('text cleanup: MARC punctuation and placeholders', () => {
  assert.equal(p.title('Electric machines :'), 'Electric machines');
  assert.equal(p.author('Ullman, David G.,'), 'Ullman, David G.');
  assert.equal(p.author('[ بدون مؤلف ]'), null);
  assert.equal(p.publisher('[Cengage Learning]'), 'Cengage Learning');
  assert.equal(p.publisher('Wiley,'), 'Wiley');
  assert.equal(p.subjects('Machinery -'), 'Machinery');
  assert.equal(p.year('[2001]'), 2001);
  assert.equal(p.year(''), null);
});

test('publisher spelled in different case becomes one name', () => {
  const canon = p.publisherCanonicalizer(['springer', 'Springer', 'New Age International', 'New Age international']);
  assert.equal(canon('springer'), 'Springer');
  assert.equal(canon('New Age international'), 'New Age International');
});

test('every place alias points at a real place, and every article type is defined', () => {
  const ids = new Set(PLACES.map((x) => x.id));
  for (const [alias, id] of Object.entries(PLACE_BY_SHEET_NAME)) assert.ok(ids.has(id), `${alias} → ${id}`);
  const types = new Set(ARTICLE_TYPES.map((t) => t.id));
  for (const [raw, id] of Object.entries(ARTICLE_TYPE_BY_SHEET_NAME)) assert.ok(types.has(id), `${raw} → ${id}`);
  assert.equal(PLACE_BY_SHEET_NAME[p.placeKey('Nwe Delhi:')], 'new-delhi');
  assert.equal(PLACE_BY_SHEET_NAME[p.placeKey('[Washington, D.C.]')], 'washington');
  assert.equal(PLACE_BY_SHEET_NAME[p.placeKey('Iran+:')], 'iran');
});
