import { Router } from 'express';
import { env } from '../lib/env.js';

/**
 * Shared book links — https://<this host>/book/<name>-<bibid>.
 *
 * Two jobs live here because they have to live on this host: Android only
 * opens the app for a link when the host proves it belongs to the app.
 */
export const linksRouter = Router();

/** Android App Links verification. */
linksRouter.get('/.well-known/assetlinks.json', (_req, res) => {
  const fingerprints = env.ANDROID_SHA256.split(',')
    .map((f) => f.trim().toUpperCase())
    .filter((f) => f.length > 0);

  res.setHeader('Cache-Control', 'public, max-age=3600');
  res.json([
    {
      relation: ['delegate_permission/common.handle_all_urls'],
      target: {
        namespace: 'android_app',
        package_name: env.ANDROID_PACKAGE,
        sha256_cert_fingerprints: fingerprints,
      },
    },
  ]);
});

/**
 * Someone without the app opened a book link: send them to the landing page,
 * keeping the whole path (and ?lang=) so it can show the same book. Anyone
 * with the app never reaches this — Android hands the link to the app first.
 */
// `/dalili/` is the prefix the first shared links used; both are served.
linksRouter.get(['/book/:slug', '/dalili/:slug'], (req, res, next) => {
  if (env.LANDING_URL.length === 0) return next();
  const base = env.LANDING_URL.endsWith('/') ? env.LANDING_URL.slice(0, -1) : env.LANDING_URL;
  res.redirect(302, `${base}${req.originalUrl}`);
});
