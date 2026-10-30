import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js';
import { buildCorsOptions } from './config/cors.js';
import { apiRateLimiter } from './middlewares/rateLimit.js';

const app = express();

// Necessario para obter o IP real de clientes atras de proxy
app.set('trust proxy', false);

// Middlewares globais
app.use(cors(buildCorsOptions()));
app.use(express.json({ limit: '1mb' }));
app.use('/api', apiRateLimiter);

// Rota de verificacao de integridade da API
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'Make Your Card API',
    uptime: process.uptime(),
  });
});

// Rotas de autenticacao e usuario
app.use('/api/auth', authRoutes);

// Tratamento de rota nao encontrada
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota nao encontrada.',
  });
});

// Tratamento global de erros
app.use((err, req, res, next) => {
  if (err.message === 'Origem nao permitida pelo CORS.') {
    return res.status(403).json({
      success: false,
      message: 'Origem nao permitida.',
    });
  }

  console.error('Erro nao tratado na aplicacao:', err.message);
  const status = err.type === 'entity.too.large' ? 413
    : err.type === 'entity.parse.failed' ? 400 : 500;
  res.status(status).json({
    success: false,
    message: status === 413 ? 'Corpo da requisicao excede o limite de 1 MB.'
      : status === 400 ? 'JSON invalido.' : 'Erro interno no servidor.',
  });
});

export default app;
