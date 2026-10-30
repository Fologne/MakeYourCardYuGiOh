import 'dotenv/config';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import mongoose from 'mongoose';
import app from '../src/app.js';
import User from '../src/models/User.js';
import { connectDatabase } from '../src/config/db.js';
import { validateEnvironment } from '../src/config/env.js';

// Usa apenas cadastros temporarios desta execucao e os remove ao terminar.
validateEnvironment();
await connectDatabase();
await User.init();
const server = app.listen(0, '127.0.0.1');
await new Promise((resolve) => server.once('listening', resolve));
const base = `http://127.0.0.1:${server.address().port}/api/auth`;
const suffix = randomUUID().replaceAll('-', '').slice(0, 16);
const usernames = [`test_${suffix}_a`, `test_${suffix}_b`];
async function request(path, method = 'GET', body, token) {
  const res = await fetch(`${base}${path}`, { method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    ...(body ? { body: JSON.stringify(body) } : {}) });
  return { status: res.status, body: await res.json() };
}
try {
  const payload = { firstName: 'Teste', lastName: 'Temporario', username: usernames[0], email: `${usernames[0]}@example.invalid`, birthDate: '2000-02-29', password: 'test-only-12345' };
  const first = await request('/register', 'POST', payload);
  assert.equal(first.status, 201);
  const oldToken = first.body.token;
  const stored = await User.findOne({ username: usernames[0] });
  assert.ok(stored); assert.notEqual(stored.password, payload.password);
  assert.match(stored.accountId, /^MYC-\d{6}$/);
  assert.equal(first.body.user.password, undefined);
  assert.equal((await request('/register', 'POST', payload)).status, 409);
  const second = await request('/register', 'POST', { ...payload, username: usernames[1], email: `${usernames[1]}@example.invalid` });
  assert.equal(second.status, 201); assert.notEqual(second.body.user.accountId, first.body.user.accountId);
  assert.equal((await request('/login', 'POST', { identifier: usernames[0], password: 'wrong' })).status, 401);
  const login = await request('/login', 'POST', { identifier: usernames[0], password: payload.password });
  assert.equal(login.status, 200);
  const newEmail = `updated_${suffix}@example.invalid`;
  const updated = await request('/profile', 'PUT', { email: newEmail, preferredPronoun: 'Mestre' }, oldToken);
  assert.equal(updated.status, 200); assert.equal(updated.body.user.email, newEmail);
  assert.equal((await User.findById(stored._id)).preferredPronoun, 'Mestre');
  assert.equal((await request('/profile', 'PUT', { email: second.body.user.email }, oldToken)).status, 409);
  assert.equal((await request('/profile', 'PUT', { birthDate: '2000-02-31' }, oldToken)).status, 400);
  assert.equal((await request('/deactivate', 'POST', {}, oldToken)).status, 200);
  assert.equal((await request('/me', 'GET', null, oldToken)).status, 401);
  const reactivated = await request('/login', 'POST', { identifier: newEmail, password: payload.password });
  assert.equal(reactivated.status, 200); assert.equal(reactivated.body.reactivated, true);
  assert.equal((await request('/me', 'GET', null, oldToken)).status, 401);
  assert.equal((await request('/me', 'GET', null, reactivated.body.token)).status, 200);
  assert.equal((await request('/account', 'DELETE', null, reactivated.body.token)).status, 200);
  assert.equal(await User.findById(stored._id), null);
  assert.equal((await request('/me', 'GET', null, reactivated.body.token)).status, 401);
  console.log('Integracao aprovada: registro, hash, duplicidade, login, perfil, persistencia, desativacao, revogacao, reativacao e exclusao.');
} finally {
  await User.deleteMany({ username: { $in: usernames } });
  await new Promise((resolve) => server.close(resolve));
  await mongoose.disconnect();
}
