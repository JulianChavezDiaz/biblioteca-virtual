export default function Home() {
  return (
    <main style={{ fontFamily: 'system-ui', padding: 40, lineHeight: 1.6 }}>
      <h1>📚 Biblioteca Digital — API</h1>
      <p>Backend Next.js + Postgres. Las rutas viven bajo <code>/api</code>.</p>
      <ul>
        <li><code>POST /api/auth/register</code></li>
        <li><code>POST /api/auth/login</code></li>
        <li><code>GET /api/books</code> · <code>GET /api/videos</code> · <code>GET /api/categories</code></li>
        <li><code>GET /api/health</code></li>
      </ul>
    </main>
  );
}
