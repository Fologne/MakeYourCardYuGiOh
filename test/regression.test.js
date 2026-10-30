import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import jwt from 'jsonwebtoken';
import app from '../src/app.js';
import User from '../src/models/User.js';
import { createRateLimiter } from '../src/middlewares/rateLimit.js';
import { authenticateToken } from '../src/middlewares/authMiddleware.js';
import { updateProfile } from '../src/controllers/authController.js';
import { validateBirthDate, calculateAge, validateAuthBody } from '../src/utils/validation.js';

process.env.JWT_SECRET = 'regression-test-secret-only';
const server = app.listen(0, '127.0.0.1');
await new Promise((resolve) => server.once('listening', resolve));
const base = `http://127.0.0.1:${server.address().port}`;
after(() => new Promise((resolve) => server.close(resolve)));
function response() {
  return { code: 200, set() {}, status(code) { this.code = code; return this; }, json(body) { this.body = body; return this; } };
}

test('limites independentes: 15 autenticacoes e bloqueio da 16a', () => {
  const api = createRateLimiter({ maxAttempts: 300, windowMs: 1000 });
  const auth = createRateLimiter({ maxAttempts: 15, windowMs: 1000 });
  const req = { ip: 'test' };
  for (let i = 0; i < 200; i++) api(req, response(), () => {});
  for (let i = 1; i <= 16; i++) {
    const res = response(); let allowed = false;
    api(req, res, () => auth(req, res, () => { allowed = true; }));
    assert.equal(allowed, i <= 15);
    if (i === 16) assert.equal(res.code, 429);
  }
});

test('datas impossiveis, tipos incorretos, futuro e menores sao rejeitados', () => {
  for (const value of ['2000-02-31', '1900-02-29', '0000-01-01', 12345, null, {}, '2999-01-01', new Date().toISOString().slice(0, 10)]) {
    assert.equal(validateBirthDate(value).valid, false, JSON.stringify(value));
  }
  assert.equal(validateBirthDate('2000-02-29').valid, true);
  assert.equal(validateBirthDate('2000-02-29T00:00:00.000').valid, true);
  assert.equal(calculateAge(new Date('2000-10-28Z'), new Date('2026-10-27Z')), 25);
  assert.equal(calculateAge(new Date('2000-10-28Z'), new Date('2026-10-28Z')), 26);
});

test('campos de perfil invalidos nao chegam ao controller', () => {
  for (const body of [{ firstName: {} }, { email: 10 }, { firstName: ' ' }, { lastName: 'a'.repeat(121) }, { preferredPronoun: 'invalido' }, { plan: 'Premium' }, {}]) {
    const res = response(); let called = false;
    validateAuthBody('profile')({ body }, res, () => { called = true; });
    assert.equal(called, false); assert.equal(res.code, 400);
  }
});

test('HTTP distingue JSON invalido e corpo muito grande sem expor detalhes', async () => {
  for (const [body, expected] of [['{', 400], [JSON.stringify({ value: 'x'.repeat(1024 * 1024) }), 413]]) {
    const res = await fetch(`${base}/api/auth/register`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body });
    assert.equal(res.status, expected);
    assert.equal(Object.hasOwn(await res.json(), 'error'), false);
  }
});

test('tipos invalidos no registro retornam 400 sem consultar banco', async () => {
  const res = await fetch(`${base}/api/auth/register`, { method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ firstName: {}, lastName: 'Teste', username: 'teste', email: 'a@b.com', birthDate: '2000-01-01', password: '123456' }) });
  assert.equal(res.status, 400);
});

test('proxy desabilitado e origens nao autorizadas rejeitadas', async () => {
  assert.equal(app.get('trust proxy'), false);
  const res = await fetch(`${base}/api/health`, { headers: { Origin: 'https://untrusted.invalid' } });
  assert.equal(res.status, 403);
});

test('token antigo, expirado e sem versao retornam 401', async () => {
  for (const token of ['invalid', jwt.sign({ id: '507f1f77bcf86cd799439011' }, process.env.JWT_SECRET),
    jwt.sign({ id: '507f1f77bcf86cd799439011', sessionVersion: 0 }, process.env.JWT_SECRET, { expiresIn: -1 })]) {
    const res = await fetch(`${base}/api/auth/me`, { headers: { Authorization: `Bearer ${token}` } });
    assert.equal(res.status, 401);
  }
});

test('token revogado continua bloqueado apos reativacao', async (t) => {
  t.mock.method(User, 'findById', () => ({ select: async () => ({ isActive: true, sessionVersion: 1 }) }));
  const token = jwt.sign({ id: '507f1f77bcf86cd799439011', sessionVersion: 0 }, process.env.JWT_SECRET);
  const res = response(); let called = false;
  await authenticateToken({ headers: { authorization: `Bearer ${token}` } }, res, () => { called = true; });
  assert.equal(called, false); assert.equal(res.code, 401);
});

test('falha de banco nao e apresentada como token invalido', async (t) => {
  const failure = new Error('database unavailable');
  t.mock.method(User, 'findById', () => ({ select: async () => { throw failure; } }));
  const token = jwt.sign({ id: '507f1f77bcf86cd799439011', sessionVersion: 0 }, process.env.JWT_SECRET);
  let forwarded;
  await authenticateToken({ headers: { authorization: `Bearer ${token}` } }, response(), (error) => { forwarded = error; });
  assert.equal(forwarded, failure);
});

test('colisao de email durante atualizacao retorna 409', async () => {
  const res = response();
  await updateProfile({ body: { firstName: 'Teste' }, user: { save: async () => { throw Object.assign(new Error('duplicate'), { code: 11000 }); } } }, res);
  assert.equal(res.code, 409); assert.equal(Object.hasOwn(res.body, 'error'), false);
});

test('serializacao do usuario remove senha e versao de sessao', () => {
  const user = new User({ password: 'hash', sessionVersion: 3, birthDate: new Date('2000-01-01') });
  assert.equal(Object.hasOwn(user.toSafeObject(), 'password'), false);
  assert.equal(Object.hasOwn(user.toSafeObject(), 'sessionVersion'), false);
});
