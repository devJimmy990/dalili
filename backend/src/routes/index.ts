import { Router } from 'express';
import { prisma } from '../lib/prisma.js';
import { sendSuccess } from '../lib/http.js';
import { asyncRoute } from '../middleware/error.js';
import { booksRouter } from './books.routes.js';
import { departmentsRouter } from './departments.routes.js';
import { placesRouter } from './places.routes.js';

export const apiRouter = Router();

/// GET /api/health — also proves the database is reachable, which is
/// what usually breaks (Neon sleeps an idle branch).
apiRouter.get(
  '/health',
  asyncRoute(async (_req, res) => {
    const [departments, books, articles] = await prisma.$transaction([
      prisma.department.count(),
      prisma.book.count(),
      prisma.article.count(),
    ]);
    sendSuccess(res, {
      ok: true,
      database: 'connected',
      counts: { departments, books, articles },
      timestamp: new Date().toISOString(),
    });
  }),
);

apiRouter.use('/books', booksRouter);
apiRouter.use('/departments', departmentsRouter);
apiRouter.use('/places', placesRouter);
