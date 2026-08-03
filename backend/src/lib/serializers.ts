// Convierte los objetos camelCase de Prisma a JSON snake_case, replicando la
// forma exacta que devolvía Supabase para que los modelos Flutter
// (BookModel.fromJson, VideoModel.fromJson, etc.) funcionen sin cambios.

/* eslint-disable @typescript-eslint/no-explicit-any */

export function bookJson(b: any) {
  return {
    id: b.id,
    title: b.title,
    author: b.author,
    description: b.description,
    cover_url: b.coverUrl,
    file_url: b.fileUrl,
    format: b.format,
    categories: b.categories ?? [],
    category: b.category,
    subcategory: b.subcategory,
    isbn: b.isbn,
    year: b.year,
    published_date: b.publishedDate,
    is_physical: b.isPhysical,
    physical_location: b.physicalLocation,
    codigo_fisico: b.codigoFisico,
    is_physical_only: b.isPhysicalOnly,
    created_at: b.createdAt,
    created_by: b.createdBy,
  };
}

export function videoJson(v: any) {
  return {
    id: v.id,
    title: v.title,
    description: v.description,
    thumbnail_url: v.thumbnailUrl,
    video_id: v.videoId,
    category: v.category,
    subcategory: v.subcategory,
    duration: v.duration,
    views: v.views,
    created_by: v.createdBy,
    created_at: v.createdAt,
    updated_at: v.updatedAt,
  };
}

export function userJson(u: any) {
  return {
    id: u.id,
    email: u.email,
    name: u.name,
    role: u.role,
    is_active: u.isActive,
    created_at: u.createdAt,
  };
}

export function categoryJson(c: any) {
  return {
    id: c.id,
    name: c.name,
    description: c.description,
    is_active: c.isActive,
    created_by: c.createdBy,
    created_at: c.createdAt,
  };
}

export function supportRequestJson(r: any) {
  return {
    id: r.id,
    user_id: r.userId,
    title: r.title,
    description: r.description,
    type: r.type,
    status: r.status,
    created_at: r.createdAt,
    resolved_at: r.resolvedAt,
    // La app lee tanto user_name/user_email como el objeto anidado users{}.
    user_name: r.user?.name ?? null,
    user_email: r.user?.email ?? null,
    users: r.user ? { name: r.user.name, email: r.user.email } : null,
  };
}
