const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

/**
 * Inicializa la base de datos automáticamente si no existe
 */
async function initializeDatabase() {
  const adminPool = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 5432),
    database: 'postgres', // Conectarse a BD por defecto
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
  });

  try {
    await adminPool.connect();
    console.log('✓ Conectado a PostgreSQL');

    const dbName = process.env.DB_NAME || 'biblioteca';

    // Verificar si la base de datos existe
    const result = await adminPool.query(
      "SELECT 1 FROM pg_database WHERE datname = $1",
      [dbName]
    );

    if (result.rows.length === 0) {
      console.log(`📁 Creando base de datos '${dbName}'...`);
      await adminPool.query(`CREATE DATABASE ${dbName}`);
      console.log(`✓ Base de datos '${dbName}' creada`);

      // Ejecutar schema
      const schemaPath = path.join(__dirname, '..', 'migration', 'setup_local_postgres.sql');
      if (fs.existsSync(schemaPath)) {
        const schemaSql = fs.readFileSync(schemaPath, 'utf8');
        
        // Conectarse a la nueva BD y ejecutar schema
        const dbClient = new Client({
          host: process.env.DB_HOST || 'localhost',
          port: Number(process.env.DB_PORT || 5432),
          database: dbName,
          user: process.env.DB_USER || 'postgres',
          password: process.env.DB_PASSWORD || 'postgres',
        });

        await dbClient.connect();
        
        // Ejecutar script en porciones (dividir por ;)
        const statements = schemaSql
          .split(';')
          .map(s => s.trim())
          .filter(s => s.length > 0 && !s.startsWith('--'));

        for (const statement of statements) {
          try {
            await dbClient.query(statement);
          } catch (err) {
            console.warn(`⚠️  Error ejecutando statement (continuando): ${err.message}`);
          }
        }

        await dbClient.end();
        console.log('✓ Schema creado exitosamente');
      } else {
        console.warn(`⚠️  No se encontró archivo de schema en ${schemaPath}`);
      }
    } else {
      console.log(`✓ Base de datos '${dbName}' ya existe`);
    }

    await adminPool.end();
    return true;
  } catch (error) {
    console.error('❌ Error inicializando BD:', error.message);
    await adminPool.end();
    throw error;
  }
}

module.exports = { initializeDatabase };
