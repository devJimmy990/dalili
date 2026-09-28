import cors from 'cors';
import express from 'express';
import morgan from 'morgan';
import { env } from './lib/env.js';
import { errorHandler, notFoundHandler } from './middleware/error.js';
import { langMiddleware } from './middleware/lang.js';
import { apiRouter } from './routes/index.js';

export function createApp() {
  const app = express();

  app.set('trust proxy', 1);
  app.use(
    cors({
      origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(',').map((s) => s.trim()),
    }),
  );
  app.use(express.json({ limit: '1mb' }));
  app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));
  app.use(langMiddleware);

  app.get('/', (_req, res) => {
    res.json({
      status: 'success',
      data: { name: 'Dalili API', version: 1, docs: '/api/health' },
    });
  });

  app.use('/api', apiRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
