# Dalili — shared-link page

What someone sees when they open a shared book link **without the app**:
the book, where it sits in the library, and a button to get the app. If they
*do* have the app, Android opens it instead and this page is never shown.

```
https://<host>/dalili/<book-name>-<bibid>
              e.g. /dalili/construction-detailing-for-landscape-12554857
```

The name only makes the link readable in a chat. The **BibID after the last
hyphen** is the key — titles repeat and get corrected, a BibID does not. A
renamed book's old links keep working.

## Run it

```bash
cd web
npm install
cp .env.example .env     # optional: the defaults point at the live API
npm run dev              # http://localhost:5173/dalili/anything-12554857
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
3. `vercel.json` rewrites `/dalili/*` to the app, so deep links do not 404.

## Making links open the app (Android)

This is the part that is easy to get wrong. Tapping a link only opens the app
if **the host proves it belongs to the app**, by serving
`/.well-known/assetlinks.json` with the fingerprint of the key the app is
signed with. Two places can be that host:

- **The API on Render** (the default in `mobile/.env`: `SHARE_BASE_URL`). It
  already serves the file — set `ANDROID_SHA256` there. People *without* the
  app are redirected to this page when `LANDING_URL` is set on the API.
- **This site on Vercel.** It also ships `public/.well-known/assetlinks.json`.
  If you would rather share Vercel links, set `SHARE_BASE_URL` in
  `mobile/.env` to the Vercel URL and rebuild the app: the Android manifest
  takes its host from that same value, so they cannot drift apart.

The committed fingerprint is the **debug** key of the machine this was built
on. A build signed with any other key (a release key, a colleague's laptop)
needs its own fingerprint added:

```bash
keytool -list -v -keystore <your.keystore> -alias <alias> | grep SHA256
```

Verification can be checked on a device:

```bash
adb shell pm get-app-links com.example.dalili
```

`verified` next to the host means a tapped link opens the app directly.
