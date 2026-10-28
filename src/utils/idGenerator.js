import crypto from 'crypto';

// Gera um ID de conta aleatorio no formato MYC-XXXXXX
export function generateRandomAccountId() {
  const number = crypto.randomInt(100000, 999999);
  return `MYC-${number}`;
}

// Garante a unicidade do ID de conta consultando o modelo de usuario
export async function generateUniqueAccountId(UserModel) {
  let uniqueId = null;
  let isUnique = false;
  let attempts = 0;
  const maxAttempts = 10;

  while (!isUnique && attempts < maxAttempts) {
    attempts++;
    const candidateId = generateRandomAccountId();
    const existing = await UserModel.findOne({ accountId: candidateId }).lean();
    if (!existing) {
      uniqueId = candidateId;
      isUnique = true;
    }
  }

  if (!uniqueId) {
    throw new Error('Falha ao gerar ID unico de conta apos multiplas tentativas.');
  }

  return uniqueId;
}
