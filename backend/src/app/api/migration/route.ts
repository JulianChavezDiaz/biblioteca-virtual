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
      .select('*, book_stats (*)')
      .limit(5);

    for (const book of data ?? []) {
      let fileUrl = book.file_url;
      let fileName = "";
      let coverUrl = book.cover_url;
      let coverName = "";
      const current = new Date().getTime();
      if (book.file_url && book.file_url.includes('https://pnefkrshzhlelycbxhqg.supabase.co/')) {
        fileUrl = `uploads/books/${current}.pdf`
        fileName = `${current}.pdf`
      }

      if (book.cover_url && book.cover_url.includes('https://pnefkrshzhlelycbxhqg.supabase.co/')) {
        const extension = book.cover_url.split('.').pop()?.toLowerCase();
        coverUrl = `uploads/covers/${current}.${extension}`
        coverName = `${current}.${extension}`
      }

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


      if(book.book_stats && book.book_stats.id){
        await prisma.book_stats.create({
          data: {
            book_id: booknew.id,
            open_count: book.book_stats.open_count,
            created_at: book.book_stats.created_at,
            updated_at: book.book_stats.updated_at
          },
        })
      }


      if (book.file_url && book.file_url.includes('https://pnefkrshzhlelycbxhqg.supabase.co/')) {
        const pathfile = book.file_url.split('/Libros_digitales/')[1];
        const downloadfile = await supabase.storage
          .from('Libros_digitales')
          .download(pathfile);
        if (!downloadfile.data) continue;

        const buffer = Buffer.from(
          await downloadfile.data.arrayBuffer()
        );



        const dir = path.join(process.cwd(), 'public', 'uploads', 'books');
        await mkdir(dir, { recursive: true });
        await writeFile(path.join(dir, fileName), buffer);
        console.log(`${book.title} migrado`);
      }

      if (book.cover_url && book.cover_url.includes('https://pnefkrshzhlelycbxhqg.supabase.co/')) {
        const pathcover = book.cover_url.split('/Libros_digitales/')[1];
        const downloadcover = await supabase.storage
          .from('Libros_digitales')
          .download(pathcover);
        if (!downloadcover.data) continue;

        const buffer = Buffer.from(
          await downloadcover.data.arrayBuffer()
        );

        const dir = path.join(process.cwd(), 'public', 'uploads', 'covers');
        await mkdir(dir, { recursive: true });
        await writeFile(path.join(dir, coverName), buffer);
        console.log(`${book.title} migrado`);
      }
    }

    if (error) throw error;
    return ok("");
  });
}
