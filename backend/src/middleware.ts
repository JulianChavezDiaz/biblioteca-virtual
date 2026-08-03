import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// Habilita CORS para todas las rutas /api/* (la app Flutter web corre en otro origen)
// y responde los preflight OPTIONS.
const ORIGIN = process.env.CORS_ORIGIN || '*';

export function middleware(req: NextRequest) {
  const res =
    req.method === 'OPTIONS'
      ? new NextResponse(null, { status: 204 })
      : NextResponse.next();

  res.headers.set('Access-Control-Allow-Origin', ORIGIN);
  res.headers.set('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.headers.set('Access-Control-Max-Age', '86400');
  return res;
}

export const config = {
  matcher: ['/api/:path*', '/uploads/:path*'],
};
