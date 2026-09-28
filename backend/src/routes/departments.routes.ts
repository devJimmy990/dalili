import { Router } from 'express';
import { z } from 'zod';
import { env } from '../lib/env.js';
import { notFound, param, sendSuccess } from '../lib/http.js';
import { asyncRoute } from '../middleware/error.js';
import { listBooks } from '../services/books.service.js';
import { getDepartmentById, listDepartments } from '../services/departments.service.js';

export const departmentsRouter = Router();

const pageQuery = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(env.PAGE_SIZE),
});

/// GET /api/departments
departmentsRouter.get(
  '/',
  asyncRoute(async (req, res) => {
    sendSuccess(res, { items: await listDepartments(req.lang) });
  }),
);

/// GET /api/departments/:id
departmentsRouter.get(
  '/:id',
  asyncRoute(async (req, res) => {
    const department = await getDepartmentById(param(req, 'id'), req.lang);
    if (!department) throw notFound('department_not_found');
    sendSuccess(res, { department });
  }),
);

/// GET /api/departments/:id/books?page=1&limit=20
/// A 404 here means the department id is wrong; an empty page means the
/// section exists on the map but has no books catalogued yet.
departmentsRouter.get(
  '/:id/books',
  asyncRoute(async (req, res) => {
    const { page, limit } = pageQuery.parse(req.query);
    const id = param(req, 'id');
    const department = await getDepartmentById(id, req.lang);
    if (!department) throw notFound('department_not_found');
    const books = await listBooks({ page, limit }, req.lang, { departmentId: id });
    sendSuccess(res, { ...books, department });
  }),
);
