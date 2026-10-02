# Dalili API

Backend for the Dalili smart-library app. Express + Prisma + PostgreSQL (Neon).
It replaces the old Google Apps Script (kept for reference in `docs/legacy/`).

## Setup

```bash
cd backend
npm install
cp .env.example .env     # then paste your Neon connection string
npx prisma generate
npx prisma db push       # creates the tables
npm run seed             # loads data/Datasource.xlsx
npm test                 # unit-tests the spreadsheet parsers
npm run dev              # http://localhost:3000
```

Check it came up:

```bash
curl http://localhost:3000/api/health
```

### Getting the Neon URL

Neon dashboard → your project → **Connection Details** → copy the **pooled**
connection string (the host contains `-pooler`). Keep `?sslmode=require`.

## Scripts

| Command | What it does |
| --- | --- |
| `npm run dev` | Dev server, restarts on save |
| `npm run build` / `npm start` | Compile to `dist/`, then run it |
| `npm run typecheck` | Types only, no output |
| `npm run seed` | Load the spreadsheet into the database |
| `npm run seed -- --dry-run` | Validate the spreadsheet without writing anything |
| `npm run db:reset` | Drop everything, recreate, re-seed |
| `npm run prisma:studio` | Browse the data in a GUI |

## API

Every response is wrapped:

```json
{ "status": "success", "data": { ... } }
{ "status": "error",   "message": "لم يتم العثور على الكتاب" }
```

Add `?lang=ar` or `?lang=en` to anything (default `ar`; `Accept-Language` is
used as a fallback). Language affects department names, place names, the
edition/shelf/language labels, document types, and error messages — never the
book's own title or author.

| Method | Path | Notes |
| --- | --- | --- |
| GET | `/api/health` | Also verifies the database is awake |
| GET | `/api/books` | Paginated. `?page=1&limit=20&department=d_electrical&author=Wadhwa` |
| GET | `/api/books/search?q=...` | All matches in one response, no paging |
| GET | `/api/books/by-ids?ids=42432,188693` | Keeps the requested order — used by Favorites |
| GET | `/api/books/:id` | `404` when unknown |
| GET | `/api/books/:id/articles` | Related articles, best score first |
| GET | `/api/departments` | Every section, each with `bookCount` |
| GET | `/api/departments/:id` | |
| GET | `/api/departments/:id/books` | Paginated; empty page ≠ `404` |
| GET | `/api/places` | Publication cities |

Paginated responses carry `items`, `total`, `page`, `limit`, `totalPages`,
`hasMore`.

### A book

```json
{
  "id": "12492294",
  "callNumber": "621.3193.W H",
  "title": "High Voltage Engineering",
  "author": "Wadhwa, C.L.",
  "edition": 3,
  "editionLabel": "الثالثة",
  "editionType": { "id": "standard", "name": "طبعة عادية" },
  "editionInferred": false,
  "publisher": "New Age International",
  "place": { "id": "new-delhi", "name": "نيودلهي" },
  "year": 2010,
  "subjects": "Voltage Engineering.",
  "shelf": 31,
  "shelfLabel": "الرف 31",
  "department": { "id": "d_electrical", "name": "كهرباء", "mapNodeId": "d_electrical" },
  "location": { "nodeId": "d_electrical", "name": "كهرباء" },
  "locationLabel": "قسم كهرباء، الرف 31",
  "language": "الإنجليزية",
  "languages": [{ "id": "en", "name": "الإنجليزية", "role": "TEXT" }],
  "cover": "https://...",
  "isbn": "9788122430905",
  "articles": [ ... ]
}
```

`location.nodeId` is a node id in the app's `library_map.json`, so the app can
hand it straight to the navigation engine. It is `null` for a section that is
not on the map yet.

## Data notes

The spreadsheet (`data/Datasource.xlsx`, sheets `books` and `articles`) is
the librarians' working copy. `prisma/seed.ts` normalizes it on the way in;
the cell-level rules live in `prisma/sheet-parsers.ts` and the lookup tables
in `prisma/lookups.ts`. Run `npm run seed -- --dry-run` to validate the sheet
and see every repair it makes without touching the database.

Anything shown in two languages is a table with `nameAr` / `nameEn` and an id —
departments, places, languages, edition types, article types, source types —
and rows point at the id. Sections and cities live in `prisma/reference-data.ts`
(the sheet only names them; an unknown name aborts the seed).

- **Language is many-to-many with a role.** `العربية (مترجم عن الإنجليزية)` is
  Arabic text *translated from* English; `الكورية والإنجليزية` is two text
  languages. The API returns `language` (display text) and `languages` (ids).
- **Edition is three fields.** The number (`2nd. ed`, `ط. 1` → 2, 1), the kind
  (standard / international / teacher / not stated `[د.ط]`), and
  `editionInferred` when the sheet printed it in `[brackets]` (supplied by the
  cataloguer, not stated on the book). `[1st. ed]` is shown as "[الأولى]" / "[1st]" and
  `1st. ed` as "الأولى" / "1st" — brackets appear only where the sheet has them.
- **Shelf is the sheet's number** (13–68), a library-wide shelf code, shown as
  "الرف 31". `locationLabel` is "قسم كهرباء، الرف 31".
- **Document types are merged** from 15 spellings into six (مقال, بحث, مقال
  مراجعة, بحث مؤتمر, مقال رأي, مقال إرشادي). A document whose source is a
  conference is always a conference paper. The source type (مجلة / مؤتمر) is
  separate.
- **Articles get a stable id** (hash of the DOI, else the title), and an article
  listed under two books is one row linked to both.
- **ISBNs that lost their leading zero in Excel are restored** — only when the
  padded number passes the ISBN-10 checksum. A number that fails its checksum is
  kept as typed and listed in the seed report.
- **Free text is cleaned**, not translated: trailing MARC punctuation
  (`Electric machines :`), `[Cengage Learning]`, `Wiley,`, and publishers
  spelled in different case become one name.
- **Basic Sciences shares the Mechanical node.** The map has no separate node, so
  `MAP_NODE_OVERRIDES` points `d_basic_sciences` at `d_mechanical`.
- **Blank means NULL.** A column is `NOT NULL` only when the record cannot exist
  without it (`id`, `callNumber`, `title`, `departmentId`). A book with no author
  is stored with `NULL` and shown as "مؤلف غير معروف".

## Deploying to Render

`render.yaml` is a blueprint: Render dashboard → **New → Blueprint** → pick this
repo. It creates the service and asks for `DATABASE_URL` (the only secret; it is
deliberately not in the file). Health check is `/api/health`.

The blueprint runs `prisma db push` before each deploy, which suits a schema
that is still moving. Once you start committing migrations, swap the
`preDeployCommand` for `npx prisma migrate deploy`.

### Configuring the service by hand instead

If you create the service through the dashboard rather than the blueprint:

| Field | Value |
| --- | --- |
| Root Directory | `backend/` |
| Build Command | `npm ci --include=dev && npx prisma generate && npm run build` |
| Start Command | `npm start` |
| Health Check Path | `/api/health` |
| Environment | `DATABASE_URL` (the Neon string), `NODE_ENV=production` |

`--include=dev` is not optional. Render sets `NODE_ENV=production`, which
makes npm skip devDependencies — and TypeScript plus every `@types/*` package
lives there, so the build fails on missing type declarations without it.
