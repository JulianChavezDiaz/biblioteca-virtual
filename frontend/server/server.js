const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const { isStrongPassword, hasRequiredRole } = require('./security');
const { initializeDatabase } = require('./db-init');

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;
const jwtSecret = process.env.JWT_SECRET;
const allowedOrigins = (process.env.CORS_ORIGIN || 'http://localhost:3000,http://localhost:5173,http://localhost:8080')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'biblioteca',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

app.disable('x-powered-by');
app.use(cors({
  origin(origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    return callback(new Error('Origen no permitido'));
  },
  credentials: false,
}));
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: false, limit: '100kb' }));
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  next();
});

const rateLimitStore = new Map();
function rateLimitMiddleware(req, res, next) {
  const ip = req.ip || req.headers['x-forwarded-for'] || 'unknown';
  const now = Date.now();
  const entry = rateLimitStore.get(ip) || { count: 0, resetAt: now + 60000 };

  if (now > entry.resetAt) {
    entry.count = 0;
    entry.resetAt = now + 60000;
  }

  if (entry.count >= 20) {
    return res.status(429).json({ error: 'Demasiadas solicitudes, intente más tarde' });
  }

  entry.count += 1;
  rateLimitStore.set(ip, entry);
  next();
}

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 5 * 1024 * 1024, files: 1 },
  fileFilter(req, file, cb) {
    const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) return cb(null, true);
    cb(new Error('Tipo de archivo no permitido'));
  },
});
app.use('/uploads', express.static('uploads'));
app.use('/api/auth/login', rateLimitMiddleware);
app.use('/api/auth/register', rateLimitMiddleware);
app.use('/api/uploads', rateLimitMiddleware);

function signToken(payload) {
  if (!jwtSecret) throw new Error('JWT_SECRET no configurado');
  return jwt.sign(payload, jwtSecret, { expiresIn: '8h' });
}

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Token requerido' });
  if (!jwtSecret) return res.status(500).json({ error: 'Configuración de seguridad inválida' });

  try {
    const decoded = jwt.verify(token, jwtSecret);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Token inválido' });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!hasRequiredRole(req.user, roles)) {
      return res.status(403).json({ error: 'Permiso denegado' });
    }
    next();
  };
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function mapUserRow(row) {
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    role: row.role || 'lector',
    created_at: row.created_at,
  };
}

function mapBookRow(row) {
  return {
    id: row.id,
    title: row.title,
    author: row.author,
    description: row.description,
    cover_url: row.cover_url,
    file_url: row.file_url,
    format: row.format,
    category: row.category,
    categories: row.categories || [],
    created_at: row.created_at,
    created_by: row.created_by,
    isbn: row.isbn,
    year: row.year,
  };
}

function mapVideoRow(row) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    thumbnail_url: row.thumbnail_url,
    video_id: row.video_id,
    category: row.category,
    duration: row.duration,
    views: row.views || 0,
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}

function mapSupportRow(row) {
  return {
    id: row.id,
    user_id: row.user_id,
    user_name: row.user_name,
    user_email: row.user_email,
    title: row.title || 'Solicitud de soporte',
    description: row.request_text || row.description || '',
    type: row.type || 'otro',
    status: row.status || 'pendiente',
    created_at: row.created_at,
    resolved_at: row.resolved_at,
  };
}

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.post('/api/auth/register', async (req, res) => {
  const { email, password, name } = req.body;
  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Campos obligatorios' });
  }
  if (!isValidEmail(email)) {
    return res.status(400).json({ error: 'Correo electrónico inválido' });
  }
  if (!isStrongPassword(password)) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 12 caracteres, incluir mayúscula, minúscula, número y símbolo' });
  }

  try {
    const passwordHash = await bcrypt.hash(password, 12);
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, role, created_at)
       VALUES ($1, $2, $3, $4, NOW()) RETURNING id, email, name, role, created_at`,
      [email.toLowerCase(), passwordHash, name.trim(), 'lector']
    );

    const user = result.rows[0];
    const token = signToken({ id: user.id, email: user.email, role: user.role });
    res.json({ token, user: mapUserRow(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password || !isValidEmail(email)) {
    return res.status(400).json({ error: 'Correo electrónico o contraseña inválidos' });
  }
  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email.toLowerCase()]);
    if (result.rows.length === 0) return res.status(401).json({ error: 'Credenciales inválidas' });

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Credenciales inválidas' });

    const token = signToken({ id: user.id, email: user.email, role: user.role });
    res.json({ token, user: mapUserRow(user) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

app.get('/api/auth/me', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json({ user: mapUserRow(result.rows[0]) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener usuario' });
  }
});

app.post('/api/auth/reset-password', async (req, res) => {
  res.json({ ok: true, message: 'Reset password no implementado' });
});

app.get('/api/books', async (req, res) => {
  const { search, category, limit } = req.query;
  let query = 'SELECT * FROM books WHERE 1=1';
  const values = [];
  if (search) {
    values.push(`%${search}%`);
    query += ` AND (title ILIKE $${values.length} OR author ILIKE $${values.length})`;
  }
  if (category) {
    values.push(category);
    query += ` AND category ILIKE $${values.length}`;
  }
  if (limit) {
    values.push(Number(limit));
    query += ` ORDER BY created_at DESC LIMIT $${values.length}`;
  }
  try {
    const result = await pool.query(query, values);
    res.json(result.rows.map(mapBookRow));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener libros' });
  }
});

app.get('/api/books/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM books WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Libro no encontrado' });
    res.json(mapBookRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener libro' });
  }
});

app.post('/api/books', authMiddleware, async (req, res) => {
  const { title, author, description, file_url, cover_url, format, category, isbn, year } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO books (title, author, description, file_url, cover_url, format, category, isbn, year, created_at, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), $10)
       RETURNING *`,
      [title, author, description, file_url, cover_url, format || 'pdf', category, isbn, year, req.user.id]
    );
    res.status(201).json(mapBookRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear libro' });
  }
});

app.put('/api/books/:id', authMiddleware, async (req, res) => {
  const { title, author, description, file_url, cover_url, format, category, isbn, year } = req.body;
  try {
    const result = await pool.query(
      `UPDATE books SET title=$1, author=$2, description=$3, file_url=$4, cover_url=$5, format=$6, category=$7, isbn=$8, year=$9, updated_at=NOW()
       WHERE id=$10 RETURNING *`,
      [title, author, description, file_url, cover_url, format || 'pdf', category, isbn, year, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Libro no encontrado' });
    res.json(mapBookRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar libro' });
  }
});

app.delete('/api/books/:id', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM books WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Libro no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al borrar libro' });
  }
});

app.get('/api/videos', async (req, res) => {
  const { search, category } = req.query;
  let query = 'SELECT * FROM videos WHERE 1=1';
  const values = [];
  if (search) {
    values.push(`%${search}%`);
    query += ` AND title ILIKE $${values.length}`;
  }
  if (category) {
    values.push(category);
    query += ` AND category ILIKE $${values.length}`;
  }
  try {
    const result = await pool.query(query, values);
    res.json(result.rows.map(mapVideoRow));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener videos' });
  }
});

app.get('/api/videos/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM videos WHERE id = $1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Video no encontrado' });
    res.json(mapVideoRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener video' });
  }
});

app.post('/api/videos', authMiddleware, async (req, res) => {
  const { title, description, thumbnail_url, video_id, category, duration } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO videos (title, description, thumbnail_url, video_id, category, duration, views, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, 0, NOW(), NOW()) RETURNING *`,
      [title, description, thumbnail_url, video_id, category, duration]
    );
    res.status(201).json(mapVideoRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear video' });
  }
});

app.put('/api/videos/:id', authMiddleware, async (req, res) => {
  const { title, description, thumbnail_url, video_id, category, duration } = req.body;
  try {
    const result = await pool.query(
      `UPDATE videos SET title=$1, description=$2, thumbnail_url=$3, video_id=$4, category=$5, duration=$6, updated_at=NOW() WHERE id=$7 RETURNING *`,
      [title, description, thumbnail_url, video_id, category, duration, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Video no encontrado' });
    res.json(mapVideoRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar video' });
  }
});

app.delete('/api/videos/:id', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM videos WHERE id = $1 RETURNING id', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Video no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al borrar video' });
  }
});

app.get('/api/categories', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT DISTINCT COALESCE(category, 'General') AS name
       FROM books
       WHERE COALESCE(category, '') <> ''
       UNION
       SELECT DISTINCT COALESCE(category, 'General') AS name
       FROM videos
       WHERE COALESCE(category, '') <> ''
       ORDER BY name`
    );
    res.json(result.rows.map((row) => ({ name: row.name, description: row.name })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

app.post('/api/categories', authMiddleware, async (req, res) => {
  const { name, description } = req.body;
  res.status(201).json({ name, description, note: 'Categoría guardada como valor derivado de libros/videos' });
});

app.put('/api/categories/:id', authMiddleware, async (req, res) => {
  const { name, description } = req.body;
  res.json({ name, description, note: 'Categoría actualizada como valor derivado' });
});

app.delete('/api/categories/:id', authMiddleware, async (req, res) => {
  res.json({ ok: true });
});

app.get('/api/users', authMiddleware, requireRole('admin'), async (req, res) => {
  try {
    const result = await pool.query('SELECT id, email, name, role, created_at FROM users ORDER BY created_at DESC');
    res.json(result.rows.map(mapUserRow));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener usuarios' });
  }
});

app.patch('/api/users/:id', authMiddleware, requireRole('admin'), async (req, res) => {
  const { role } = req.body;
  try {
    await pool.query('UPDATE users SET role=$1 WHERE id=$2', [role, req.params.id]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar rol' });
  }
});

app.delete('/api/users/:id', authMiddleware, requireRole('admin'), async (req, res) => {
  try {
    await pool.query('DELETE FROM users WHERE id=$1', [req.params.id]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al borrar usuario' });
  }
});

app.post('/api/favorites', authMiddleware, async (req, res) => {
  const { bookId } = req.body;
  try {
    await pool.query('INSERT INTO favorites (user_id, book_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [req.user.id, bookId]);
    res.status(201).json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar favorito' });
  }
});

app.get('/api/favorites', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT book_id FROM favorites WHERE user_id=$1', [req.user.id]);
    res.json(result.rows.map(row => row.book_id));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener favoritos' });
  }
});

app.get('/api/favorites/:bookId', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query('SELECT 1 FROM favorites WHERE user_id=$1 AND book_id=$2', [req.user.id, req.params.bookId]);
    res.json({ isFavorite: result.rows.length > 0 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al verificar favorito' });
  }
});

app.delete('/api/favorites/:bookId', authMiddleware, async (req, res) => {
  try {
    await pool.query('DELETE FROM favorites WHERE user_id=$1 AND book_id=$2', [req.user.id, req.params.bookId]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al borrar favorito' });
  }
});

app.post('/api/books/:bookId/open', authMiddleware, async (req, res) => {
  res.json({ ok: true });
});

app.post('/api/reading-progress', authMiddleware, async (req, res) => {
  const { bookId, progress } = req.body;
  try {
    const existing = await pool.query(
      'SELECT id FROM reading_history WHERE user_id = $1 AND book_id = $2',
      [req.user.id, bookId]
    );

    if (existing.rows.length > 0) {
      await pool.query(
        'UPDATE reading_history SET progress = $1, last_read = NOW() WHERE id = $2',
        [progress, existing.rows[0].id]
      );
    } else {
      await pool.query(
        'INSERT INTO reading_history (user_id, book_id, progress, last_read) VALUES ($1, $2, $3, NOW())',
        [req.user.id, bookId, progress]
      );
    }

    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar progreso' });
  }
});

app.get('/api/stats/recent', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT b.id, b.title, b.author, b.cover_url, b.file_url, rh.progress, rh.last_read AS updated_at
       FROM reading_history rh
       JOIN books b ON b.id = rh.book_id
       WHERE rh.user_id = $1
       ORDER BY rh.last_read DESC LIMIT 10`,
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener estadísticas recientes' });
  }
});

app.get('/api/stats/top-books', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT b.id, b.title, b.author, b.cover_url, b.file_url, COUNT(rp.book_id) as opens
       FROM books b
       LEFT JOIN reading_progress rp ON rp.book_id = b.id
       GROUP BY b.id
       ORDER BY opens DESC LIMIT 10`
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener top books' });
  }
});

app.get('/api/support-requests', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM requests WHERE user_id = $1 OR $2 = 'admin' ORDER BY created_at DESC`,
      [req.user.id, req.user.role]
    );
    res.json(result.rows.map(mapSupportRow));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener solicitudes' });
  }
});

app.post('/api/support-requests', authMiddleware, async (req, res) => {
  const { title, description, type } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO requests (user_id, user_name, user_email, title, request_text, status, created_at)
       VALUES ($1, $2, $3, $4, $5, 'pendiente', NOW()) RETURNING *`,
      [req.user.id, req.user.name || 'Usuario', req.user.email || '', title || 'Solicitud', description || '', type || 'otro']
    );
    res.status(201).json(mapSupportRow(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear solicitud' });
  }
});

app.patch('/api/support-requests/:id', authMiddleware, requireRole('admin'), async (req, res) => {
  try {
    await pool.query('UPDATE requests SET status = $1 WHERE id = $2', ['resuelto', req.params.id]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al actualizar solicitud' });
  }
});

app.delete('/api/support-requests/:id', authMiddleware, requireRole('admin'), async (req, res) => {
  try {
    await pool.query('DELETE FROM requests WHERE id = $1', [req.params.id]);
    res.json({ ok: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al borrar solicitud' });
  }
});

app.post('/api/uploads', authMiddleware, upload.single('file'), async (req, res) => {
  const file = req.file;
  if (!file) return res.status(400).json({ error: 'Archivo requerido' });
  res.json({ url: `/uploads/${file.filename}` });
});

app.use((err, req, res, next) => {
  if (err && err.message === 'Origen no permitido') {
    return res.status(403).json({ error: 'Origen no permitido' });
  }
  if (err instanceof multer.MulterError) {
    return res.status(400).json({ error: 'Error al subir archivo' });
  }
  if (err && err.message === 'Tipo de archivo no permitido') {
    return res.status(400).json({ error: err.message });
  }
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

// Inicializar base de datos e iniciar servidor
(async () => {
  try {
    console.log('🔧 Inicializando base de datos...');
    await initializeDatabase();
    
    app.listen(port, async () => {
      console.log(`✅ Backend escuchando en http://localhost:${port}`);
      try {
        await pool.query('SELECT 1');
        console.log('✓ Conexión a PostgreSQL OK');
      } catch (err) {
        console.log('❌ Conexión a PostgreSQL fallida:', err.message);
      }
    });
  } catch (err) {
    console.error('❌ Error al inicializar la aplicación:', err.message);
    process.exit(1);
  }
})();
