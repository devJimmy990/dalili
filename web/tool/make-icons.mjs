/**
 * Builds the site's icons from the app's own logo, so the website and the
 * Android app show the same picture.
 *
 *   npm run icons
 *
 * The source is mobile/assets/images/logo.png. The app's launcher icon is that
 * logo resized to a square (it is slightly wider than tall), so the same
 * resize is used here — otherwise the two would not quite match.
 *
 * Writes to public/: favicon.ico, favicon-16.png, favicon-32.png,
 * apple-touch-icon.png, icon-96.png, icon-192.png, icon-512.png.
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const here = dirname(fileURLToPath(import.meta.url));
const SOURCE = resolve(here, '../../mobile/assets/images/logo.png');
const OUT = resolve(here, '../public');

/** The logo as a square of [size] px, squeezed the way the launcher icon is. */
const square = (size) =>
  sharp(readFileSync(SOURCE))
    .resize(size, size, { fit: 'fill', kernel: 'lanczos3' })
    .png({ compressionLevel: 9 })
    .toBuffer();

/**
 * An .ico that holds PNG images. Every browser from the last decade reads
 * them, and it avoids a bitmap encoder: the file is a small directory
 * followed by the PNGs themselves.
 */
function ico(images) {
  const header = Buffer.alloc(6);
  header.writeUInt16LE(1, 2); // type: icon
  header.writeUInt16LE(images.length, 4);

  let offset = 6 + images.length * 16;
  const entries = images.map(({ size, data }) => {
    const entry = Buffer.alloc(16);
    entry.writeUInt8(size >= 256 ? 0 : size, 0); // width (0 means 256)
    entry.writeUInt8(size >= 256 ? 0 : size, 1); // height
    entry.writeUInt16LE(1, 4); // colour planes
    entry.writeUInt16LE(32, 6); // bits per pixel
    entry.writeUInt32LE(data.length, 8);
    entry.writeUInt32LE(offset, 12);
    offset += data.length;
    return entry;
  });

  return Buffer.concat([header, ...entries, ...images.map((i) => i.data)]);
}

mkdirSync(OUT, { recursive: true });

const files = {
  'favicon-16.png': 16,
  'favicon-32.png': 32,
  'apple-touch-icon.png': 180,
  // Shown in the page header at about 36px (72px on a 2x screen).
  'icon-96.png': 96,
  'icon-192.png': 192,
  'icon-512.png': 512,
};

for (const [name, size] of Object.entries(files)) {
  writeFileSync(resolve(OUT, name), await square(size));
  console.log(`  ${name}  ${size}x${size}`);
}

const sizes = [16, 32, 48];
const images = await Promise.all(sizes.map(async (size) => ({ size, data: await square(size) })));
writeFileSync(resolve(OUT, 'favicon.ico'), ico(images));
console.log(`  favicon.ico  ${sizes.join(', ')}`);
