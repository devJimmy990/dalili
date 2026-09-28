import { createApp } from './app.js';
import { env } from './lib/env.js';
import { prisma } from './lib/prisma.js';

const server = createApp().listen(env.PORT, () => {
  console.log(`Dalili API listening on http://localhost:${env.PORT} (${env.NODE_ENV})`);
});

// Close the pool on shutdown; Neon counts a dangling connection
// against the branch limit until it times out.
for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.on(signal, () => {
    server.close(() => {
      void prisma.$disconnect().finally(() => process.exit(0));
    });
  });
}
