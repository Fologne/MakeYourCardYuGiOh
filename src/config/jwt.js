// Centraliza a leitura e validacao do segredo JWT
export function getJwtSecret() {
  const secret = process.env.JWT_SECRET;

  if (!secret || secret.trim().length < 16) {
    throw new Error('JWT_SECRET nao configurado ou com menos de 16 caracteres.');
  }

  return secret;
}

export function getJwtExpiresIn() {
  return process.env.JWT_EXPIRES_IN || '7d';
}
