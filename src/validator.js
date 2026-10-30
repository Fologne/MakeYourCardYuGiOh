import dotenv from 'dotenv';
import { pathToFileURL } from 'node:url';

dotenv.config();

const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-3.8-flash';
const GEMINI_FALLBACK_MODEL = process.env.GEMINI_FALLBACK_MODEL || 'gemini-3.6-flash';
const HF_IMAGE_MODEL = process.env.HF_IMAGE_MODEL || '';

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Valida a IA de texto usando a API REST do Gemini, com retentativa e modelo alternativo
export async function validarGemini() {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error('Chave GEMINI_API_KEY nao configurada.');
  }

  const models = [...new Set([GEMINI_MODEL, GEMINI_FALLBACK_MODEL])];
  let lastError = null;

  for (const model of models) {
    for (let attempt = 1; attempt <= 2; attempt++) {
      console.log(`Testando IA de Texto (Gemini - ${model}, tentativa ${attempt})...`);

      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
        const response = await fetch(url, {
          signal: AbortSignal.timeout(30000),
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'x-goog-api-key': process.env.GEMINI_API_KEY },
          body: JSON.stringify({
            contents: [{ parts: [{ text: 'Responda apenas: Conexao de texto estabelecida com sucesso.' }] }],
          }),
        });

        if (!response.ok) {
          const detail = await response.text();
          throw new Error(`Gemini respondeu ${response.status}: ${detail.slice(0, 300)}`);
        }

        const data = await response.json();
        const text = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
        if (!text) throw new Error('Gemini retornou resposta sem texto.');
        console.log('Resposta Texto:', text);
        return;
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await sleep(3000);
        }
      }
    }
  }

  throw lastError || new Error('Falha desconhecida na IA de texto.');
}

// Valida a geracao de imagem gratuita via Pollinations
async function validarPollinations() {
  console.log('Testando IA de Imagem (Pollinations)...');

  const prompt = encodeURIComponent('dragao branco de olhos azuis, estilo anime');
  const url = `https://image.pollinations.ai/prompt/${prompt}?width=512&height=512&nologo=true`;
  const response = await fetch(url, { signal: AbortSignal.timeout(60000) });

  if (!response.ok) {
    throw new Error(`Pollinations respondeu ${response.status}.`);
  }

  const contentType = response.headers.get('content-type') || '';
  const buffer = await response.arrayBuffer();

  if (!contentType.startsWith('image/') || buffer.byteLength < 1000) {
    throw new Error('Pollinations nao retornou uma imagem valida.');
  }

  console.log(`Resposta Imagem: ${(buffer.byteLength / 1024).toFixed(1)} KB recebidos.`);
}

// Valida a API de imagem da Hugging Face quando a chave e o modelo estiverem configurados
async function validarHuggingFace() {
  if (!process.env.HUGGINGFACE_API_KEY || !HF_IMAGE_MODEL) {
    console.log('Hugging Face nao configurada. Pollinations e o provedor de imagem padrao.');
    return;
  }

  console.log(`Testando IA de Imagem (Hugging Face - ${HF_IMAGE_MODEL})...`);

  const response = await fetch(
    `https://router.huggingface.co/hf-inference/models/${HF_IMAGE_MODEL}`,
    {
      signal: AbortSignal.timeout(60000),
      method: 'POST',
      headers: {
        Authorization: `Bearer ${process.env.HUGGINGFACE_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ inputs: 'dragao branco de olhos azuis, estilo anime' }),
    }
  );

  if (!response.ok) {
    throw new Error(`Hugging Face respondeu ${response.status}: ${response.statusText}`);
  }

  const contentType = response.headers.get('content-type') || '';
  const buffer = await response.arrayBuffer();

  if (!contentType.startsWith('image/') || buffer.byteLength < 1000) {
    throw new Error('Hugging Face nao retornou uma imagem valida.');
  }

  console.log(`Resposta Imagem HF: ${(buffer.byteLength / 1024).toFixed(1)} KB recebidos.`);
}

async function validarConexaoIA() {
  console.log('Verificacao de conectividade e resposta dos provedores. Nao valida regras, balanceamento ou integracao com o aplicativo.');
  let falhas = 0;

  try {
    await validarGemini();
  } catch (error) {
    falhas++;
    console.error('Falha na IA de texto:', error.message);
  }

  try {
    await validarPollinations();
  } catch (error) {
    falhas++;
    console.error('Falha na IA de imagem (Pollinations):', error.message);
  }

  try {
    await validarHuggingFace();
  } catch (error) {
    console.error('Aviso da Hugging Face:', error.message);
  }

  if (falhas > 0) {
    console.error(`Validacao concluida com ${falhas} falha(s).`);
    process.exit(1);
  }

  console.log('Verificacao de conectividade concluida. Rotas e fluxos de IA do aplicativo ainda nao implementados.');
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) validarConexaoIA();
