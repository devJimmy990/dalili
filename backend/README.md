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
npm run seed             # loads data/Dalili.xlsx
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
ordinal labels, and error messages — never the book's own title or author.

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
  "publisher": "New Age International,",
  "place": { "id": "new-delhi", "name": "نيودلهي" },
  "year": 2010,
  "subjects": "Voltage Engineering.",
  "shelf": 3,
  "shelfLabel": "الثالث",
  "department": { "id": "d_electrical", "name": "كهرباء", "mapNodeId": "d_electrical" },
  "location": { "nodeId": "d_electrical", "name": "كهرباء" },
  "language": "en",
  "cover": "https://...",
  "isbn": "9788122430905",
  "articles": [ ... ]
}
```

`location.nodeId` is a node id in the app's `library_map.json`, so the app can
hand it straight to the navigation engine. It is `null` for a section that is
not on the map yet.

## Data notes

The spreadsheet is the librarians' working copy, so `prisma/seed.ts` normalizes
it on the way in. What it fixes, and why:

- **Department codes.** `Books.department_id` uses `d1..d5`; the Departments
  sheet uses slugs. `DEPARTMENT_ALIASES` maps them (`d1` → `d_electrical`, …).
  An unmapped code aborts the seed rather than orphaning books.
- **`location` is dropped.** It duplicated `department_id`. A book's location is
  its department's place on the map, so the API derives it.
- **Basic Sciences shares the Mechanical node.** The two sections sit together
  and the map has no separate node, so `MAP_NODE_OVERRIDES` points
  `d_basic_sciences` at `d_mechanical`.
- **Ordinals become integers.** `"3rd"` → `3`, localized at response time.
  Non-numeric editions (`"international"`, `"teacher"`) survive in
  `editionLabel`; `"Null"` becomes `null`.
- **Years are cleaned.** `"[2001]"` → `2001`.
- **Article links are unpacked.** `Articles.book_ids` packs ids with a
  `/*-*/` separator into the `book_articles` join table.
- **Blank means NULL.** A column is `NOT NULL` only when the record cannot
  exist without it (`id`, `callNumber`, `title`, `author`, `departmentId`).
  Everything else is stored as `NULL` when the cell is blank, never as `""`.

### Known gap in the source data

Nine books have an ISBN that Excel stored as a float and rounded, losing the
trailing digits (`9788120000000`). The digits are gone from the source, so the
seed keeps the value and prints the list. To fix: format the `isbn` column as
**Text** in `data/Dalili.xlsx`, re-enter those nine, and re-run `npm run seed`.

## Deploying to Render

`render.yaml` is a blueprint: Render dashboard → **New → Blueprint** → pick this
repo. It creates the service and asks for `DATABASE_URL` (the only secret; it is
deliberately not in the file). Health check is `/api/health`.

The blueprint runs `prisma db push` before each deploy, which suits a schema
that is still moving. Once you start committing migrations, swap the
`preDeployCommand` for `npx prisma migrate deploy`.
