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
  /// Where people without the app land when they open a shared book link
  /// (the React page, e.g. https://dalili.vercel.app). Empty: no redirect.
  LANDING_URL: z.string().default(''),
  /// SHA-256 fingerprint(s) of the key the Android app is signed with,
  /// comma-separated. They let Android verify that this host really belongs
  /// to the app, so a tapped book link opens it instead of the browser.
  ANDROID_SHA256: z.string().default(''),
  ANDROID_PACKAGE: z.string().default('com.example.dalili'),
});

const parsed = schema.safeParse(process.env);

if (!parsed.success) {
  const issues = parsed.error.issues.map((i) => `  - ${i.path.join('.')}: ${i.message}`).join('\n');
  console.error(`Invalid environment configuration:\n${issues}`);
  process.exit(1);
}

export const env = parsed.data;
