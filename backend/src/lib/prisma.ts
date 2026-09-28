import { PrismaClient } from '@prisma/client';
import { env } from './env.js';

// One client per process. `globalThis` keeps a single instance alive
// across tsx-watch reloads, which would otherwise exhaust Neon's
// connection limit with a new pool on every file save.
const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
  });

if (env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
