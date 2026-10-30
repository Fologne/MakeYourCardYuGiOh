import dotenv from 'dotenv';
import mongoose from 'mongoose';
import app from './app.js';
import { connectDatabase } from './config/db.js';
import { validateEnvironment } from './config/env.js';

dotenv.config();

const PORT = Number(process.env.PORT || 3000);

async function startServer() {
  try {
    // Valida as variaveis obrigatorias antes de conectar ao banco
    validateEnvironment();

    // Conecta ao MongoDB antes de iniciar o servidor HTTP
    await connectDatabase();

    const server = app.listen(PORT, () => {
      console.log(`Servidor Make Your Card rodando na porta ${PORT}`);
      console.log(`Rotas de autenticacao disponiveis em http://localhost:${PORT}/api/auth`);
    });

    // Tratamento de encerramento seguro
    const gracefulShutdown = () => {
      console.log('Encerrando servidor de forma segura...');
      const deadline = setTimeout(() => process.exit(1), 10000);
      deadline.unref();
      server.close(async () => {
        await mongoose.disconnect();
        console.log('Servidor HTTP encerrado.');
        process.exit(0);
      });
    };

    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);
  } catch (error) {
    console.error('Falha fatal ao iniciar o servidor:', error.message);
    process.exit(1);
  }
}

startServer();
