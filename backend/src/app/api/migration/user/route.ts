import type { NextRequest } from 'next/server';
import { prisma } from '@/lib/db';
import { getAuthUser, hasRole, UPLOAD_ROLES } from '@/lib/auth';
import { ok, fail, withErrors } from '@/lib/http';
import { bookJson } from '@/lib/serializers';
import { supabase } from '@/lib/supabase';
import path from 'path';
import { writeFile, mkdir } from 'fs/promises';

export const dynamic = 'force-dynamic';

// GET /api/books?search=&category=&limit=
export async function GET(req: NextRequest) {
  return withErrors(async () => {
  const { data, error } = await supabase
  .from('books')
  .select('*')
  .limit(5);

  for (const book of data ?? []) {
  const booknew = await prisma.book.create({
      data: {
        title: book.title,
        author: book.author,
        description: book.description ?? null,
        coverUrl: coverUrl,
        fileUrl: fileUrl,
        format: book.format ?? null,
        categories: Array.isArray(book.categories) ? book.categories : [],
        category: book.category ?? null,
        subcategory: book.subcategory ?? null,
        isbn: book.isbn ?? null,
        year: book.year ?? null,
        publishedDate: book.published_date ? new Date(book.published_date) : null,
        isPhysical: book.is_physical ?? false,
        physicalLocation: book.physical_location ?? null,
        codigoFisico: book.codigo_fisico ?? null,
        isPhysicalOnly: book.is_physical_only ?? false,
        createdBy: book.created_by,
      },
    });


  }

if (error) throw error;
    return ok("");
  

  });
}
