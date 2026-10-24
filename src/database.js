import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

async function validarConexaoBanco() {
  console.log('Iniciando validacao de conexao com o MongoDB...');

  try {
    if (!process.env.DB_URI) {
      throw new Error('Variavel DB_URI nao configurada no arquivo .env.');
    }

    // Configura o mongoose e conecta ao banco
    await mongoose.connect(process.env.DB_URI);
    
    console.log('Conexao com o MongoDB Atlas estabelecida com sucesso.');
    console.log('Etapa 2 concluida com exito. Infraestrutura de banco de dados pronta.');
    
    // Encerra a conexao após o teste
    await mongoose.connection.close();
    process.exit(0);

  } catch (error) {
    console.error('Erro ao conectar ao banco de dados:', error.message);
    process.exit(1);
  }
}

validarConexaoBanco();