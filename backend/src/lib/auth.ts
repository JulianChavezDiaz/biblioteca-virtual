import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import type { NextRequest } from 'next/server';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me';
const JWT_EXPIRES_IN = '7d';

// Roles que pueden subir/editar contenido (libros, videos, categorías).
export const UPLOAD_ROLES = ['admin', 'bibliotecario', 'profesor'];
// Roles que pueden borrar contenido o gestionar.
export const DELETE_ROLES = ['admin', 'bibliotecario'];
export const ADMIN_ROLES = ['admin'];

export interface AuthUser {
  sub: string; // id de usuario
  email: string;
  name: string;
  role: string;
}

export function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, 10);
}

export function verifyPassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}

export function signToken(payload: AuthUser): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

/** Extrae y valida el usuario desde el header Authorization: Bearer <token>. */
export function getAuthUser(req: NextRequest): AuthUser | null {
  const header = req.headers.get('authorization');
  if (!header?.startsWith('Bearer ')) return null;
  try {
    return jwt.verify(header.slice(7), JWT_SECRET) as AuthUser;
  } catch {
    return null;
  }
}

export function hasRole(user: AuthUser | null, roles: string[]): boolean {
  return !!user && roles.includes(user.role);
}
