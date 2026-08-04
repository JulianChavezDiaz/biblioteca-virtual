import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { hashPassword, signToken } from '@/lib/auth';
import { bookJson } from '@/lib/serializers';
import { supabase } from '@/lib/supabase';
import path from 'path';
import { writeFile, mkdir } from 'fs/promises';

export const dynamic = 'force-dynamic';

// GET /api/migration/user
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const { data, error } = await supabase
      .from('users')
      .select('*');

    for (const user of data ?? []) {
      await prisma.user.create({
        data: {
          email: user.email,
          name: user.name,
          role: user.role,
          passwordHash: await hashPassword('a123456'),
          createdAt:  new Date(user.created_at),
          isActive: user.is_active,
        },
      });
    }

    if (error) throw error;

    return ok("");
  });
}
