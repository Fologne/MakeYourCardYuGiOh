import mongoose from 'mongoose';

// Estabelece conexao com o banco de dados MongoDB Atlas
export async function connectDatabase() {
  const dbUri = process.env.DB_URI;

  if (!dbUri) {
    throw new Error('Variavel DB_URI nao configurada no arquivo .env.');
  }

  try {
    const conn = await mongoose.connect(dbUri, {
      dbName: 'makeyourcard',
      authSource: 'admin',
    });
    console.log(`Conexao com MongoDB estabelecida: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error('Erro ao conectar ao MongoDB:', error.message);
    throw error;
  }
}
