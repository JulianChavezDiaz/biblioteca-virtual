import type { NextRequest } from 'next/server';
import crypto from 'crypto';
import { prisma } from '@/lib/db';
import { ok, fail, withErrors } from '@/lib/http';
import { sendMail } from '@/lib/mailer';

export const dynamic = 'force-dynamic';

// POST /api/auth/reset-password { email }
// Genera un token de recuperación, lo guarda (hasheado) y envía un email con el
// enlace. Siempre responde OK (no revela si el email existe).
export async function POST(req: NextRequest) {
  return withErrors(async () => {
    const { email } = await req.json().catch(() => ({}));
    if (!email) return fail('Email requerido', 422);

    const user = await prisma.user.findUnique({ where: { email } });

    if (user) {
      const rawToken = crypto.randomBytes(32).toString('hex');
      const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');
      const expiresAt = new Date(Date.now() + 1000 * 60 * 60); // 1 hora

      // Invalidar tokens anteriores del usuario y crear el nuevo.
      await prisma.passwordResetToken.deleteMany({ where: { userId: user.id } });
      await prisma.passwordResetToken.create({
        data: { userId: user.id, tokenHash, expiresAt },
      });

      const appUrl = process.env.APP_URL || 'http://localhost:8080';
      const link = `${appUrl}/reset-password?token=${rawToken}`;

      await sendMail(
        user.email,
        'Restablece tu contraseña — Biblioteca Digital',
        `
          <div style="font-family: system-ui, sans-serif; max-width: 480px; margin: auto;">
            <h2>Restablecer contraseña</h2>
            <p>Hola ${user.name}, recibimos una solicitud para restablecer tu contraseña.</p>
            <p>Haz clic en el siguiente enlace (válido por 1 hora):</p>
            <p><a href="${link}" style="display:inline-block;padding:12px 20px;background:#00BCD4;color:#fff;border-radius:8px;text-decoration:none;">Restablecer contraseña</a></p>
            <p style="color:#666;font-size:13px;">Si no fuiste tú, ignora este correo.</p>
          </div>
        `,
      );
    }

    return ok({ message: 'Si el email existe, se enviaron instrucciones.' });
  });
}
