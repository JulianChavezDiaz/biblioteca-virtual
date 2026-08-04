import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';
import { supabase } from '@/lib/supabase';
import path from 'path';
import { writeFile, mkdir } from 'fs/promises';

export const dynamic = 'force-dynamic';

// GET /api/migration/video
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const { data, error } = await supabase
      .from('videos')
      .select('*')
      .limit(5);

    for (const video of data ?? []) {
      await prisma.video.create({
        data: {
          title: video.title,
          description: video.description,
          thumbnail_url: video.thumbnail_url,
          video_id: video.video_id,
          category: video.category,
          duration: video.duration,
          views: video.views,
          created_at: video.created_at,
          updated_at: video.updated_at,
          subcategory: video.subcategory
        },
      });
    }

    if (error) throw error;
    return ok("");
  });
}
