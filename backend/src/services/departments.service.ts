import { prisma } from '../lib/prisma.js';
import type { Lang } from '../lib/lang.js';
import { serializeDepartment } from '../lib/serializers.js';

/// All departments, including the ones with no books yet — they exist
/// on the library map, so the app still lets you navigate to them.
/// `bookCount` lets the UI show an empty state without a second call.
export async function listDepartments(lang: Lang) {
  const rows = await prisma.department.findMany({
    orderBy: [{ sortOrder: 'asc' }, { id: 'asc' }],
    include: { _count: { select: { books: true } } },
  });

  return rows.map((d) => ({
    ...serializeDepartment(d, lang),
    bookCount: d._count.books,
  }));
}

export async function getDepartmentById(id: string, lang: Lang) {
  const row = await prisma.department.findUnique({
    where: { id },
    include: { _count: { select: { books: true } } },
  });
  if (!row) return null;
  return { ...serializeDepartment(row, lang), bookCount: row._count.books };
}

export async function departmentExists(id: string): Promise<boolean> {
  return (await prisma.department.count({ where: { id } })) > 0;
}
