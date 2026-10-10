/**
 * Draws `assets/map/library_map.json` to an SVG floor plan, so the recorded
 * coordinates can be checked against the real library.
 *
 *   node tool/draw_map.mjs            → writes doc/library_map.svg
 *   node tool/draw_map.mjs out.svg    → writes somewhere else
 *
 * Everything is in the map's own units (meters, x east, y south — the same
 * convention NavigationPositionEngine dead-reckons in), with a 1 m grid so
 * distances can be paced out on site.
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const MAP = resolve(here, '../assets/map/library_map.json');
const OUT = resolve(here, '..', process.argv[2] ?? 'doc/library_map.svg');

const PX = 70; // pixels per meter
const PAD = 2.4; // meters of margin around the content

const COLOR = {
  bg: '#0d1b2a',
  grid: '#17263a',
  gridMajor: '#23374f',
  edge: '#4a7fb5',
  corridor: '#4a7fb5',
  destination: '#2f81f7',
  entrance: '#2ea043',
  intersection: '#7d8da1',
  label: '#e6edf3',
  dim: '#93a4b8',
  accent: '#f0b429',
};

const map = JSON.parse(readFileSync(MAP, 'utf8'));

const xs = map.nodes.map((n) => n.x);
const ys = map.nodes.map((n) => n.y);
const minX = Math.min(...xs) - PAD;
const maxX = Math.max(...xs) + PAD;
const minY = Math.min(...ys) - PAD;
const maxY = Math.max(...ys) + PAD;

const W = (maxX - minX) * PX;
const H = (maxY - minY) * PX;

/** Map coordinates → SVG pixels. y already grows downward in both. */
const px = (x) => ((x - minX) * PX).toFixed(1);
const py = (y) => ((y - minY) * PX).toFixed(1);

const byId = new Map(map.nodes.map((n) => [n.id, n]));
const esc = (s) =>
  String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const out = [];
out.push(
  `<svg xmlns="http://www.w3.org/2000/svg" width="${W.toFixed(0)}" height="${H.toFixed(0)}" viewBox="0 0 ${W.toFixed(0)} ${H.toFixed(0)}" font-family="system-ui, sans-serif">`,
);
out.push(`<rect width="100%" height="100%" fill="${COLOR.bg}"/>`);

// ── 1 m grid, heavier every 5 m, labelled in meters ──
out.push('<g>');
for (let x = Math.ceil(minX); x <= maxX; x++) {
  const major = x % 5 === 0;
  out.push(
    `<line x1="${px(x)}" y1="0" x2="${px(x)}" y2="${H.toFixed(0)}" stroke="${major ? COLOR.gridMajor : COLOR.grid}" stroke-width="${major ? 1.4 : 0.8}"/>`,
  );
  if (major) {
    out.push(
      `<text x="${px(x) - 0 + 4}" y="14" fill="${COLOR.dim}" font-size="11">x=${x}</text>`,
    );
  }
}
for (let y = Math.ceil(minY); y <= maxY; y++) {
  const major = y % 5 === 0;
  out.push(
    `<line x1="0" y1="${py(y)}" x2="${W.toFixed(0)}" y2="${py(y)}" stroke="${major ? COLOR.gridMajor : COLOR.grid}" stroke-width="${major ? 1.4 : 0.8}"/>`,
  );
  if (major) {
    out.push(
      `<text x="4" y="${Number(py(y)) - 4}" fill="${COLOR.dim}" font-size="11">y=${y}</text>`,
    );
  }
}
out.push('</g>');

// ── Corridors: the edge's real width, drawn to scale ──
out.push('<g>');
for (const e of map.edges) {
  const a = byId.get(e.from);
  const b = byId.get(e.to);
  if (!a || !b) continue; // the map test catches these; don't crash here
  const width = (e.width ?? 1.5) * PX;
  out.push(
    `<line x1="${px(a.x)}" y1="${py(a.y)}" x2="${px(b.x)}" y2="${py(b.y)}" stroke="${COLOR.corridor}" stroke-opacity="0.16" stroke-width="${width.toFixed(1)}" stroke-linecap="round"/>`,
  );
  out.push(
    `<line x1="${px(a.x)}" y1="${py(a.y)}" x2="${px(b.x)}" y2="${py(b.y)}" stroke="${COLOR.edge}" stroke-opacity="0.75" stroke-width="1.6"/>`,
  );
}
// Edge lengths, so a tape measure can confirm them.
for (const e of map.edges) {
  const a = byId.get(e.from);
  const b = byId.get(e.to);
  if (!a || !b) continue;
  const d = Math.hypot(b.x - a.x, b.y - a.y);
  if (d < 0.4) continue; // coincident nodes: nothing to measure
  const mx = (Number(px(a.x)) + Number(px(b.x))) / 2;
  const my = (Number(py(a.y)) + Number(py(b.y))) / 2;
  out.push(
    `<text x="${mx.toFixed(1)}" y="${(my - 5).toFixed(1)}" fill="${COLOR.dim}" font-size="10" text-anchor="middle">${d.toFixed(1)}m</text>`,
  );
}
out.push('</g>');

// ── Nodes ──
// Coincident nodes (two sections sharing one spot) are fanned out so both
// labels stay readable; the marker itself stays on the true coordinate.
const seenAt = new Map();
out.push('<g>');
for (const n of map.nodes) {
  const key = `${n.x},${n.y}`;
  const nth = seenAt.get(key) ?? 0;
  seenAt.set(key, nth + 1);

  const color =
    n.type === 'entrance'
      ? COLOR.entrance
      : n.type === 'destination'
        ? COLOR.destination
        : COLOR.intersection;

  // Arrival footprint, to scale.
  if (n.width && n.height) {
    out.push(
      `<rect x="${px(n.x - n.width / 2)}" y="${py(n.y - n.height / 2)}" width="${(n.width * PX).toFixed(1)}" height="${(n.height * PX).toFixed(1)}" fill="${color}" fill-opacity="0.13" stroke="${color}" stroke-opacity="0.5" stroke-dasharray="4 3" stroke-width="1.2" rx="4"/>`,
    );
  }

  const r = n.type === 'intersection' ? 4.5 : 7;
  out.push(
    `<circle cx="${px(n.x)}" cy="${py(n.y)}" r="${r}" fill="${color}" stroke="${COLOR.bg}" stroke-width="2"/>`,
  );

  const labelY = Number(py(n.y)) + (nth === 0 ? -14 : 30);
  const lines = [n.id];
  if (n.type !== 'intersection') lines.push(n.nameEn ?? n.name);
  lines.push(`(${n.x}, ${n.y})${n.qr ? ` · ${n.qr}` : ''}`);

  lines.forEach((text, i) => {
    const bold = i === 0 ? ' font-weight="600"' : '';
    const fill = i === 0 ? COLOR.label : COLOR.dim;
    const size = i === 0 ? 12 : 10.5;
    out.push(
      `<text x="${px(n.x)}" y="${(labelY + i * 12).toFixed(1)}" fill="${fill}" font-size="${size}"${bold} text-anchor="middle">${esc(text)}</text>`,
    );
  });
}
out.push('</g>');

// ── Legend ──
const lx = 12;
const ly = H - 86;
out.push(
  `<rect x="${lx - 6}" y="${ly - 16}" width="250" height="78" fill="${COLOR.bg}" fill-opacity="0.85" stroke="${COLOR.gridMajor}" rx="6"/>`,
);
const legend = [
  [COLOR.entrance, 'entrance'],
  [COLOR.destination, 'destination (dashed = arrival zone)'],
  [COLOR.intersection, 'corridor junction'],
];
legend.forEach(([c, text], i) => {
  const y = ly + i * 18;
  out.push(`<circle cx="${lx + 6}" cy="${y}" r="5" fill="${c}"/>`);
  out.push(
    `<text x="${lx + 18}" y="${y + 4}" fill="${COLOR.dim}" font-size="11">${esc(text)}</text>`,
  );
});
out.push(
  `<text x="${lx}" y="${ly + 56}" fill="${COLOR.dim}" font-size="10.5">grid = 1 m · ${map.nodes.length} nodes · ${map.edges.length} edges</text>`,
);

out.push('</svg>');

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, out.join('\n'));

console.log(`Wrote ${OUT}`);
console.log(
  `  ${map.nodes.length} nodes, ${map.edges.length} edges · ` +
    `${(maxX - minX - 2 * PAD).toFixed(1)}m x ${(maxY - minY - 2 * PAD).toFixed(1)}m of floor`,
);
