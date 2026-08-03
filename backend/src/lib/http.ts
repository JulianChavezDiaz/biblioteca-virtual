import { NextResponse } from 'next/server';

/** Respuesta JSON correcta. */
export function ok(data: unknown, status = 200) {
  return NextResponse.json(data, { status });
}

/** Respuesta de error JSON: { error: "mensaje" }. */
export function fail(message: string, status = 400) {
  return NextResponse.json({ error: message }, { status });
}

/** Envuelve un handler para capturar excepciones no controladas. */
export function withErrors(
  handler: () => Promise<NextResponse>,
): Promise<NextResponse> {
  return handler().catch((e) => {
    console.error('[API error]', e);
    return fail('Error interno del servidor', 500);
  });
}
