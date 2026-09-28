import { Router } from 'express';
import { prisma } from '../lib/prisma.js';
import { sendSuccess } from '../lib/http.js';
import { serializePlace } from '../lib/serializers.js';
import { asyncRoute } from '../middleware/error.js';

export const placesRouter = Router();

/// GET /api/places — publication cities, localized.
placesRouter.get(
  '/',
  asyncRoute(async (req, res) => {
    const rows = await prisma.place.findMany({ orderBy: { id: 'asc' } });
    sendSuccess(res, { items: rows.map((p) => serializePlace(p, req.lang)) });
  }),
);
