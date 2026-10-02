# دليلي — Dalili

Smart library assistant for an engineering faculty library: search the
catalogue, scan a book, and get walked to its shelf with indoor navigation.

```
dalili/
├─ backend/   Dalili API — Express + Prisma + PostgreSQL (Neon)
├─ mobile/    Flutter app (Android / iOS)
└─ docs/      Notes, and the retired Google Apps Script backend
```

## Getting started

Two terminals: the API, then the app.

```bash
cd backend
npm install
cp .env.example .env     # paste your Neon connection string
npx prisma db push
npm run seed
npm run dev              # http://localhost:3000
```

```bash
cd mobile
fvm flutter pub get
fvm flutter run
```

`mobile/.env` holds `API_BASE_URL`. It ships pointing at
`http://10.0.2.2:3000/api`, which is how the Android emulator reaches the API
on your machine — change it to your deployed URL, or to your LAN IP for a
physical device.

Details live in each project: [backend/README.md](backend/README.md) covers the
API, the schema and deployment.

## How the two halves meet

The API owns the catalogue and all localization: send `?lang=ar|en` and
department names, place names, edition, shelf and language labels ("الثالثة" / "3rd", "الرف 31") and error
messages come back in that language. Book titles and authors are never
translated. The Flutter app sends the active locale on every request through a
Dio interceptor.

The library map (`mobile/assets/map/library_map.json`) stays a local asset, so
navigation works offline. The link between the two is the department: each one
carries a `mapNodeId` that matches a node in that file, and every book reports
`location.nodeId`.

That link is what makes **"take me to the book"** work: the button on a book's
detail screen opens navigation with the destination already chosen, so the
reader only scans the QR code nearest to them and walks. It is disabled for a
book whose section has no node on the map. Because a mismatch between the two
sources would open a dead end, `mobile/test/navigation/` checks every
department and book against the map asset.

## History

The backend was originally a Google Apps Script reading a Google Sheet. It is
kept at [docs/legacy/app-script.gs](docs/legacy/app-script.gs) for reference
only — nothing in the app calls it any more. The spreadsheet remains the
librarians' editing surface: it lives at `backend/data/Dalili.xlsx` and
`npm run seed` loads it into Postgres.
