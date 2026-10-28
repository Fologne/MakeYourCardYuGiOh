import dotenv from 'dotenv';
import app from './app.js';
import { connectDatabase } from './config/db.js';

dotenv.config();

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Conecta ao MongoDB antes de iniciar o servidor HTTP
    await connectDatabase();

    const server = app.listen(PORT, () => {
      console.log(`Servidor Make Your Card rodando na porta ${PORT}`);
      console.log(`Rotas de autenticacao disponiveis em http://localhost:${PORT}/api/auth`);
    });

    // Tratamento de encerramento seguro
    const gracefulShutdown = () => {
      console.log('Encerrando servidor de forma segura...');
      server.close(() => {
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
