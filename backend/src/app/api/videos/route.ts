import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { videoJson } from '@/lib/serializers';

export const dynamic = 'force-dynamic';

// GET /api/videos?category=&search=
export async function GET(req: NextRequest) {
  return withErrors(async () => {
    const { searchParams } = new URL(req.url);
    const category = searchParams.get('category')?.trim();
    const search = searchParams.get('search')?.trim();

    const videos = await prisma.video.findMany({
      where: {
        AND: [
          category ? { category: { equals: category, mode: 'insensitive' } } : {},
          search
            ? {
                OR: [
                  { title: { contains: search, mode: 'insensitive' } },
                  { category: { contains: search, mode: 'insensitive' } },
                  { subcategory: { contains: search, mode: 'insensitive' } },
                ],
              }
            : {},
        ],
      },
      orderBy: { createdAt: 'desc' },
    });

    return ok(videos.map(videoJson));
  });
}

// POST /api/videos
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para subir videos', 403);

    const v = await req.json().catch(() => null);
    if (!v?.title || !v?.video_id || !v?.category) {
      return fail('title, video_id y category son obligatorios', 422);
    }

    const video = await prisma.video.create({
      data: {
        title: v.title,
        description: v.description ?? null,
        thumbnailUrl: v.thumbnail_url ?? null,
        videoId: v.video_id,
        category: v.category,
        subcategory: v.subcategory ?? null,
        duration: v.duration ?? null,
        createdBy: auth.sub,
      },
    });

    return ok(videoJson(video), 201);
  });
}
