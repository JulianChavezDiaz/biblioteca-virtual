export const metadata = {
  title: 'Biblioteca Digital API',
  description: 'Backend Next.js + Postgres',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
