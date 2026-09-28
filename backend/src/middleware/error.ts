import type { NextFunction, Request, Response } from 'express';
import { ZodError } from 'zod';
import { env } from '../lib/env.js';
import { ApiError, sendError } from '../lib/http.js';
import { msg, resolveLang } from '../lib/lang.js';

export function notFoundHandler(req: Request, res: Response): void {
  sendError(res, `${msg(req.lang ?? 'ar', 'not_found')}: ${req.method} ${req.path}`, 404);
}

export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  _next: NextFunction,
): void {
  const lang = req.lang ?? resolveLang(req.query?.lang);

  if (err instanceof ApiError) {
    sendError(res, err.localized(lang), err.statusCode);
    return;
  }

  // Bad query/params — surface which field failed, it is the client's bug.
  if (err instanceof ZodError) {
    const detail = err.issues.map((i) => `${i.path.join('.') || 'query'}: ${i.message}`).join('; ');
    sendError(res, `${msg(lang, 'invalid_request')} — ${detail}`, 422);
    return;
  }

  const detail = err instanceof Error ? err.message : String(err);
  console.error('Unhandled error:', err);
  sendError(
    res,
    env.NODE_ENV === 'production' ? msg(lang, 'server_error') : `${msg(lang, 'server_error')}: ${detail}`,
    500,
  );
}

/// Wraps an async route so a rejected promise reaches `errorHandler`
/// instead of hanging the request (Express 4 does not await handlers).
export function asyncRoute<T extends Request>(
  handler: (req: T, res: Response) => Promise<void>,
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    handler(req as T, res).catch(next);
  };
}
