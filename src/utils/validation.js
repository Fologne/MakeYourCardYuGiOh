export const GENDER_OPTIONS = ['Masculino', 'Feminino', 'Outro', 'Prefiro nao informar'];
export const GAME_ORIGIN_OPTIONS = ['TCG', 'OCG', 'Master Duel', 'Duel Links'];
export const TREATMENT_OPTIONS = ['Duelista', 'Mestre', 'Jogador', 'Invocador'];

export function calculateAge(birth, today = new Date()) {
  let age = today.getUTCFullYear() - birth.getUTCFullYear();
  if (today.getUTCMonth() < birth.getUTCMonth()
    || (today.getUTCMonth() === birth.getUTCMonth() && today.getUTCDate() < birth.getUTCDate())) age--;
  return age;
}

// Valida o dia civil sem deslocamento de fuso horario.
export function validateBirthDate(value) {
  if (typeof value !== 'string'
    || !/^\d{4}-\d{2}-\d{2}(?:T00:00:00(?:\.\d{1,3})?Z?)?$/.test(value)) {
    return { valid: false, message: 'Data de nascimento invalida.' };
  }
  const civil = value.slice(0, 10);
  const date = new Date(`${civil}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== civil || date.getUTCFullYear() < 1900) {
    return { valid: false, message: 'Data de nascimento invalida.' };
  }
  if (date > new Date()) return { valid: false, message: 'Data de nascimento nao pode estar no futuro.' };
  if (calculateAge(date) < 6) return { valid: false, message: 'A idade minima e de 6 anos.' };
  return { valid: true, date };
}

export function validateAuthBody(mode) {
  const limits = mode === 'login' ? { identifier: 254, password: 1024 }
    : { firstName: 80, lastName: 120, email: 254, birthDate: 30,
      gender: 30, gameOrigin: 20, ...(mode === 'register'
        ? { username: 40, password: 1024 } : { preferredPronoun: 20 }) };
  const required = mode === 'register'
    ? ['firstName', 'lastName', 'username', 'email', 'birthDate', 'password']
    : mode === 'login' ? ['identifier', 'password'] : [];
  return (req, res, next) => {
    const body = req.body;
    const fail = (message) => res.status(400).json({ success: false, message });
    if (!body || typeof body !== 'object' || Array.isArray(body)) return fail('Corpo da requisicao invalido.');
    if (required.some((key) => !Object.hasOwn(body, key))) return fail('Preencha os campos obrigatorios.');
    if (mode === 'profile' && Object.keys(body).length === 0) return fail('Informe os dados para atualizar.');
    for (const [key, value] of Object.entries(body)) {
      if (!Object.hasOwn(limits, key)) return fail(`Campo nao permitido: ${key}.`);
      if (typeof value !== 'string' || !value.trim() || value.length > limits[key]) return fail(`Campo invalido ou muito longo: ${key}.`);
    }
    if (body.password && mode === 'register'
      && (body.password.length < 6 || Buffer.byteLength(body.password, 'utf8') > 72)) return fail('A senha deve ter ao menos 6 caracteres e no maximo 72 bytes.');
    if (body.preferredPronoun && !TREATMENT_OPTIONS.includes(body.preferredPronoun)) return fail('Forma de tratamento invalida.');
    if (body.birthDate) {
      const result = validateBirthDate(body.birthDate);
      if (!result.valid) return fail(result.message);
    }
    return next();
  };
}
