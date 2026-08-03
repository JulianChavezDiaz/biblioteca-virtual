import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

// Usuarios iniciales (reemplaza a TestUsersService de la app Flutter).
// ⚠️  Cambia estas contraseñas antes de usar en producción.
const users = [
  { email: 'admin@yavirac.edu.ec', password: 'admin123', name: 'Administrador Yavirac', role: 'admin' },
  { email: 'bibliotecario@yavirac.edu.ec', password: 'biblio123', name: 'Bibliotecario Yavirac', role: 'bibliotecario' },
  { email: 'profesor@yavirac.edu.ec', password: 'profe123', name: 'Profesor Yavirac', role: 'profesor' },
  { email: 'lector@yavirac.edu.ec', password: 'lector123', name: 'Lector Yavirac', role: 'lector' },
];

const categories = [
  { name: 'General', description: 'Categoría por defecto' },
  { name: 'Literatura', description: 'Novelas, cuentos y poesía' },
  { name: 'Tecnología', description: 'Programación e informática' },
];

async function main() {
  console.log('🌱 Sembrando datos iniciales...');

  for (const u of users) {
    await prisma.user.upsert({
      where: { email: u.email },
      update: {},
      create: {
        email: u.email,
        name: u.name,
        role: u.role,
        passwordHash: await bcrypt.hash(u.password, 10),
      },
    });
    console.log(`  ✅ usuario ${u.email} (${u.role})`);
  }

  const admin = await prisma.user.findUnique({ where: { email: 'admin@yavirac.edu.ec' } });

  for (const c of categories) {
    const existing = await prisma.category.findFirst({ where: { name: c.name } });
    if (!existing) {
      await prisma.category.create({ data: { ...c, createdBy: admin?.id } });
      console.log(`  ✅ categoría ${c.name}`);
    }
  }

  const bookCount = await prisma.book.count();
  if (bookCount === 0) {
    await prisma.book.create({
      data: {
        title: 'El Quijote',
        author: 'Miguel de Cervantes',
        format: 'pdf',
        description: 'La obra maestra de la literatura española',
        category: 'Literatura',
        categories: ['Literatura'],
        createdBy: admin?.id,
      },
    });
    console.log('  ✅ libro de ejemplo: El Quijote');
  }

  console.log('🌱 Listo.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
