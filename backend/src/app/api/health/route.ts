import { prisma } from '@/lib/db';
import { ok, fail } from '@/lib/http';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return ok({ status: 'ok', db: 'up', time: new Date().toISOString() });
  } catch {
    return fail('db_down', 503);
  }
}
