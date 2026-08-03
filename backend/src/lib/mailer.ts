import nodemailer from 'nodemailer';

// Configuración SMTP desde variables de entorno.
const host = process.env.SMTP_HOST;
const port = Number(process.env.SMTP_PORT) || 587;
const user = process.env.SMTP_USER;
const pass = process.env.SMTP_PASS;
const from = process.env.SMTP_FROM || user;

let transporter: nodemailer.Transporter | null = null;

/** ¿Hay credenciales SMTP configuradas? */
export function isMailConfigured(): boolean {
  return Boolean(host && user && pass);
}

function getTransporter(): nodemailer.Transporter {
  if (!transporter) {
    transporter = nodemailer.createTransport({
      host,
      port,
      secure: port === 465, // 465 = SSL; 587/25 = STARTTLS
      auth: { user, pass },
    });
  }
  return transporter;
}

/**
 * Envía un correo. Si SMTP no está configurado, no lanza error: solo avisa por
 * consola y devuelve false (útil en desarrollo).
 */
export async function sendMail(
  to: string,
  subject: string,
  html: string,
): Promise<boolean> {
  if (!isMailConfigured()) {
    console.warn('[mailer] SMTP no configurado — email NO enviado a', to);
    return false;
  }
  await getTransporter().sendMail({ from, to, subject, html });
  return true;
}
