import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { videoJson } from '@/lib/serializers';
import {
  extractYouTubeVideoId,
  isYouTubeThumbnailFor,
  youtubeThumbnailUrl,
} from '@/lib/youtube';

export const dynamic = 'force-dynamic';

type Ctx = { params: Promise<{ id: string }> };

export async function GET(_req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const { id } = await params;
    const video = await prisma.video.findUnique({ where: { id } });
    if (!video) return fail('Video no encontrado', 404);
    return ok(videoJson(video));
  });
}

export async function PUT(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, UPLOAD_ROLES)) return fail('Sin permiso para editar', 403);

    const { id } = await params;
    const v = await req.json().catch(() => ({}));
    if (!v?.title?.trim() || !v?.video_id?.trim() || !v?.category?.trim()) {
      return fail('title, video_id y category son obligatorios', 422);
    }

    const current = await prisma.video.findUnique({ where: { id } });
    if (!current) return fail('Video no encontrado', 404);

    const videoId = extractYouTubeVideoId(v.video_id);
    if (!videoId) return fail('La URL o ID de YouTube no es válido', 422);

    const currentVideoId = extractYouTubeVideoId(current.videoId);
    const submittedThumbnail = v.thumbnail_url?.trim() || null;
    const thumbnailUrl =
      !submittedThumbnail ||
      (videoId !== currentVideoId &&
        isYouTubeThumbnailFor(submittedThumbnail, currentVideoId))
        ? youtubeThumbnailUrl(videoId)
        : submittedThumbnail;

    const video = await prisma.video.update({
      where: { id },
      data: {
        title: v.title.trim(),
        description: v.description,
        thumbnailUrl,
        videoId,
        category: v.category.trim(),
        subcategory: v.subcategory,
        duration: v.duration,
      },
    });

    return ok(videoJson(video));
  });
}

export async function DELETE(req: NextRequest, { params }: Ctx) {
  return withErrors(async () => {
    const auth = getAuthUser(req);
    if (!auth) return fail('No autenticado', 401);
    if (!hasRole(auth, DELETE_ROLES)) return fail('Sin permiso para borrar', 403);

    const { id } = await params;
    await prisma.video.delete({ where: { id } });
    return ok({ deleted: true });
  });
}
