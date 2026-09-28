import { Router } from 'express';
import { z } from 'zod';
import { env } from '../lib/env.js';
import { ApiError, notFound, param, sendSuccess } from '../lib/http.js';
import { asyncRoute } from '../middleware/error.js';
import { getArticlesForBook } from '../services/articles.service.js';
import { getBookById, getBooksByIds, listBooks, searchBooks } from '../services/books.service.js';

export const booksRouter = Router();

const pageQuery = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(env.PAGE_SIZE),
});

const listQuery = pageQuery.extend({
  department: z.string().trim().min(1).optional(),
  author: z.string().trim().min(1).optional(),
});

const searchQuery = z.object({
  // `q` is canonical; `query` is accepted as an alias.
  q: z.string().trim().min(1).optional(),
  query: z.string().trim().min(1).optional(),
});

const idsQuery = z.object({
  ids: z.string().trim().min(1),
});

/// GET /api/books/search?q=...
/// Declared before /:id so "search" is not read as a book id.
booksRouter.get(
  '/search',
  asyncRoute(async (req, res) => {
    const { q, query } = searchQuery.parse(req.query);
    const term = q ?? query;
    if (!term) throw new ApiError('missing_query', 400);
    sendSuccess(res, await searchBooks(term, req.lang));
  }),
);

/// GET /api/books/by-ids?ids=42432,12492294
booksRouter.get(
  '/by-ids',
  asyncRoute(async (req, res) => {
    const { ids } = idsQuery.parse(req.query);
    const list = ids.split(',').map((s) => s.trim()).filter((s) => s.length > 0);
    sendSuccess(res, { items: await getBooksByIds(list, req.lang) });
  }),
);

/// GET /api/books?page=1&limit=20&department=d_electrical&author=Wadhwa
booksRouter.get(
  '/',
  asyncRoute(async (req, res) => {
    const { page, limit, department, author } = listQuery.parse(req.query);
    sendSuccess(res, await listBooks({ page, limit }, req.lang, { departmentId: department, author }));
  }),
);

/// GET /api/books/:id
booksRouter.get(
  '/:id',
  asyncRoute(async (req, res) => {
    const book = await getBookById(param(req, 'id'), req.lang);
    if (!book) throw notFound('book_not_found');
    sendSuccess(res, { book });
  }),
);

/// GET /api/books/:id/articles
booksRouter.get(
  '/:id/articles',
  asyncRoute(async (req, res) => {
    const id = param(req, 'id');
    const book = await getBookById(id, req.lang);
    if (!book) throw notFound('book_not_found');
    sendSuccess(res, { items: await getArticlesForBook(id) });
  }),
);
