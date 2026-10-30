// Monta a lista de origens permitidas para o CORS
const DEFAULT_ORIGINS = [
  'http://localhost',
  'http://127.0.0.1',
  'http://localhost:8080',
  'http://localhost:3000',
];

export function buildCorsOptions() {
  const configured = (process.env.CORS_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  const allowedOrigins = configured.length > 0 ? configured : DEFAULT_ORIGINS;

  return {
    origin(origin, callback) {
      // Aplicativos desktop e mobile nao enviam cabecalho Origin
      if (!origin) {
        return callback(null, true);
      }

      const isLocalhost = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);

      if (isLocalhost || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(new Error('Origem nao permitida pelo CORS.'));
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    maxAge: 600,
  };
}
