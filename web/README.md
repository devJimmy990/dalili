# Dalili — shared-link page

What someone sees when they open a shared book link **without the app**:
the book, where it sits in the library, and a button to get the app. If they
*do* have the app, Android opens it instead and this page is never shown.

```
https://<host>/book/<book-name>-<bibid>
              e.g. /book/construction-detailing-for-landscape-12554857
```

The name only makes the link readable in a chat. The **BibID after the last
hyphen** is the key — titles repeat and get corrected, a BibID does not. A
renamed book's old links keep working.

## What the page shows

The book, where it sits in the library, and its **related articles**. The
articles come with the book from the API, best match first. Every article
link — the title and its DOI — opens in a **new tab**, so the book stays open
behind it. Only `http(s)` links are ever made clickable.

The list adapts to the screen:

| Width | Presentation |
| --- | --- |
| desktop, ≥ 1024px | a column **beside** the book; the page widens to fit both |
| tablet, 640–1023px | a **drawer** from the reading-end edge (right in English, left in Arabic) over a dimmed page |
| phone, < 640px | a **bottom sheet**, full width |

The drawer and the sheet are modal: focus moves into them, Tab stays inside,
Esc or a tap on the backdrop closes them, and focus returns to the button that
opened them. The desktop column is part of the page, so it does not trap focus
or dim anything; Esc still closes it.

## Run it

```bash
cd web
npm install
cp .env.example .env     # optional: the defaults point at the live API
npm run dev              # http://localhost:5173/book/anything-12554857
npm test                 # the link format
npm run build            # → dist/
```

| Variable | Purpose |
| --- | --- |
| `VITE_API_BASE_URL` | The Dalili API, with `/api`. Defaults to the Render service. |
| `VITE_APP_DOWNLOAD_URL` | Where to get the app (Play Store, an APK link). Empty hides the button. |
| `VITE_ANDROID_PACKAGE` | Package for the "Open in app" button. |

## Deploy on Vercel

1. Import the repo, set **Root Directory** to `web`. Vite is detected.
2. Add the variables above under Settings → Environment Variables.
3. `vercel.json` rewrites `/book/*` (and the older `/dalili/*`) to the app, so deep links do not 404.

## Making links open the app (Android)

Tapping a link only opens the app if **the host proves it belongs to the app**,
by serving `/.well-known/assetlinks.json` with the fingerprint of the key the
app is signed with. This site is that host: `public/.well-known/assetlinks.json`
ships with it, and `vercel.json` serves it as JSON with no redirect.

The app is pointed here by one value, `SHARE_BASE_URL` in `mobile/.env`
(currently `https://dalili-lime.vercel.app`). The Android manifest takes its link
host from that same value, so the shared links and the verified host cannot
drift apart. Changing it needs a rebuild of the app.

The committed fingerprint is the **debug** key of the machine this was built
on. A build signed with any other key (a release key, a colleague's laptop)
needs its own fingerprint added to the file:

```bash
keytool -list -v -keystore <your.keystore> -alias <alias> | grep SHA256
```

Check it on a device — `verified` next to the host means a tapped link opens
the app directly:

```bash
adb shell pm verify-app-links --re-verify com.example.dalili
adb shell pm get-app-links com.example.dalili
```

The API (Render) can serve the same verification file and redirect to this
page too (`ANDROID_SHA256`, `LANDING_URL`); that is only needed if links are
ever shared on the API's own host instead.
