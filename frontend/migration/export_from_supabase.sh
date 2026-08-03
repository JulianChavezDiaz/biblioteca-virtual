#!/bin/bash

echo "🔄 Exportando base de datos..."

DB_URL="postgresql://postgres:12345@localhost:5432/biblioteca"

pg_dump "$DB_URL" \
  --no-owner \
  --no-privileges \
  --clean \
  --if-exists \
  -f biblioteca_export.sql

echo "✅ Exportación completada: biblioteca_export.sql"
echo ""
echo "📋 Próximos pasos:"
echo "1. Revisa el archivo biblioteca_export.sql"
echo "2. Ejecuta: psql -h TU_NUEVO_SERVIDOR -U TU_USUARIO -d TU_BASE -f biblioteca_export.sql"