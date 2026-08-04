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
      .from('categories')
      .select('*').limit(5);

    for (const category of data ?? []) {
      await prisma.category.create({
        data: {
          name: category.name,
          description: category.description,
          created_at: category.created_at,
          is_active: category.is_active
        },
      });
    }

    if (error) throw error;

    return ok(data);
  });
}
