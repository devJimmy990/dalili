import 'dotenv/config';
import { z } from 'zod';

const schema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required (Neon connection string)'),
  /// Comma-separated list of allowed origins, or "*" for any.
  CORS_ORIGIN: z.string().default('*'),
  /// Default page size for paginated endpoints.
  PAGE_SIZE: z.coerce.number().int().positive().max(100).default(20),
});

const parsed = schema.safeParse(process.env);

if (!parsed.success) {
  const issues = parsed.error.issues.map((i) => `  - ${i.path.join('.')}: ${i.message}`).join('\n');
  console.error(`Invalid environment configuration:\n${issues}`);
  process.exit(1);
}

export const env = parsed.data;
