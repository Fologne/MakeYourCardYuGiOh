import express from 'express';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js';

const app = express();

// Middlewares globais
app.use(cors());
app.use(express.json());

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
  console.error('Erro nao tratado na aplicacao:', err.message);
  res.status(500).json({
    success: false,
    message: 'Erro interno no servidor.',
    error: err.message,
  });
});

export default app;
