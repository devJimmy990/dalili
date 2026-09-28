import type { NextFunction, Request, Response } from 'express';
import type { Lang } from '../lib/lang.js';
import { resolveLang } from '../lib/lang.js';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      lang: Lang;
    }
  }
}

/// Resolves `?lang=` once per request (falling back to the
/// `Accept-Language` header) so routes never parse it themselves.
export function langMiddleware(req: Request, _res: Response, next: NextFunction): void {
  const header = req.headers['accept-language']?.slice(0, 2).toLowerCase();
  req.lang = resolveLang(req.query.lang ?? header);
  next();
}
