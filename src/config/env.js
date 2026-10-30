import jwt from 'jsonwebtoken';
import { getJwtExpiresIn, getJwtSecret } from './jwt.js';

// Valida as variaveis obrigatorias antes de subir o servidor
export function validateEnvironment() {
  const required = ['DB_URI', 'JWT_SECRET'];
  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(`Variaveis de ambiente obrigatorias ausentes: ${missing.join(', ')}`);
  }

  if (process.env.JWT_SECRET.trim().length < 16) {
    throw new Error('JWT_SECRET deve ter no minimo 16 caracteres.');
  }

  const port = Number(process.env.PORT || 3000);
  if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('PORT deve estar entre 1 e 65535.');
  const probe = jwt.decode(jwt.sign({}, getJwtSecret(), { expiresIn: getJwtExpiresIn() }));
  if (probe.exp <= probe.iat) throw new Error('JWT_EXPIRES_IN deve representar uma duracao positiva.');

  const optional = ['GEMINI_API_KEY', 'HUGGINGFACE_API_KEY'];
  const notConfigured = optional.filter((key) => !process.env[key]);

  if (notConfigured.length > 0) {
    console.warn(`Variaveis de IA nao configuradas: ${notConfigured.join(', ')}`);
  }
}
