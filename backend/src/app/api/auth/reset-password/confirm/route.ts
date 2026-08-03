import type { NextRequest } from 'next/server';
import crypto from 'crypto';
import { prisma } from '@/lib/db';
import { hashPassword } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';

export const dynamic = 'force-dynamic';

// POST /api/auth/reset-password/confirm { token, password }
// Verifica el token de recuperación y cambia la contraseña.
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const { token, password } = await req.json().catch(() => ({}));
    if (!token || !password) return fail('Token y contraseña requeridos', 422);
    if (password.length < 6) {
      return fail('La contraseña debe tener al menos 6 caracteres', 422);
    }

    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const record = await prisma.passwordResetToken.findUnique({
      where: { tokenHash },
    });

    if (!record || record.expiresAt < new Date()) {
      return fail('El enlace es inválido o expiró', 400);
    }

    await prisma.user.update({
      where: { id: record.userId },
      data: { passwordHash: await hashPassword(password) },
    });
    // Consumir el token (y limpiar cualquier otro del usuario).
    await prisma.passwordResetToken.deleteMany({ where: { userId: record.userId } });

    return ok({ message: 'Contraseña actualizada correctamente' });
  });
}
