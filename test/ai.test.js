import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validarGemini } from '../src/validator.js';

test('Gemini so aprova resposta com texto', async (t) => {
  const previous = process.env.GEMINI_API_KEY;
  process.env.GEMINI_API_KEY = 'test-key';
  t.after(() => { if (previous === undefined) delete process.env.GEMINI_API_KEY; else process.env.GEMINI_API_KEY = previous; });
  t.mock.method(globalThis, 'fetch', async (url, options) => {
    assert.equal(url.includes('test-key'), false);
    assert.equal(options.headers['x-goog-api-key'], 'test-key');
    assert.ok(options.signal);
    return { ok: true, json: async () => ({ candidates: [{ content: { parts: [{ text: 'Conexao estabelecida.' }] } }] }) };
  });
  await validarGemini();
});

test('Gemini vazio tenta alternativa e termina em falha', async (t) => {
  const previous = process.env.GEMINI_API_KEY;
  process.env.GEMINI_API_KEY = 'test-key';
  t.after(() => { if (previous === undefined) delete process.env.GEMINI_API_KEY; else process.env.GEMINI_API_KEY = previous; });
  const models = [];
  t.mock.method(globalThis, 'setTimeout', (callback) => { callback(); });
  t.mock.method(globalThis, 'fetch', async (url) => {
    models.push(url);
    return { ok: true, json: async () => ({ candidates: [] }) };
  });
  await assert.rejects(validarGemini(), /sem texto/);
  assert.ok(models.length >= 2);
  assert.equal(models.length % 2, 0);
});
