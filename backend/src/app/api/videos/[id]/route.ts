import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES, DELETE_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { videoJson } from '@/lib/serializers';

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

    const video = await prisma.video.update({
      where: { id },
      data: {
        title: v.title,
        description: v.description,
        thumbnailUrl: v.thumbnail_url,
        videoId: v.video_id,
        category: v.category,
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
