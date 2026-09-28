import type { Request, Response } from 'express';
import type { Lang, MessageKey } from './lang.js';
import { msg } from './lang.js';

// Every response is wrapped so clients can branch on one field:
//   { "status": "success", "data": { ... } }
//   { "status": "error",   "message": "..." }

export function sendSuccess<T>(res: Response, data: T, statusCode = 200): void {
  res.status(statusCode).json({ status: 'success', data });
}

export function sendError(res: Response, message: string, statusCode = 400): void {
  res.status(statusCode).json({ status: 'error', message });
}

/// An error the route raises on purpose; the handler turns it into a
/// localized response using the request's `lang`.
export class ApiError extends Error {
  constructor(
    readonly key: MessageKey,
    readonly statusCode = 400,
  ) {
    super(key);
    this.name = 'ApiError';
  }

  localized(lang: Lang): string {
    return msg(lang, this.key);
  }
}

export function notFound(key: MessageKey): ApiError {
  return new ApiError(key, 404);
}

/// Reads a route parameter as a definite string. Express types params as
/// possibly-undefined, but a matched route always has them; an empty one
/// means the client sent something like `/books//articles`.
export function param(req: Request, name: string): string {
  const value = req.params[name]?.trim();
  if (!value) throw new ApiError('invalid_request', 400);
  return value;
}
