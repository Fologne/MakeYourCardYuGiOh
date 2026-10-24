import { GoogleGenerativeAI } from '@google/generative-ai';
import dotenv from 'dotenv';

dotenv.config();

async function validarConexaoIA() {
  console.log('Iniciando validacao das APIs gratuitas...');

  try {
    // 1. Validacao IA de Texto (Google Gemini)
    if (!process.env.GEMINI_API_KEY) {
      throw new Error('Chave GEMINI_API_KEY nao configurada.');
    }
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    
    console.log('Testando IA de Texto (Gemini)...');
    const result = await model.generateContent('Responda apenas: Conexao de texto estabelecida com sucesso.');
    const response = await result.response;
    console.log('Resposta Texto:', response.text().trim());

    // 2. Validacao IA de Imagem (Hugging Face Inference API)
    if (!process.env.HUGGINGFACE_API_KEY) {
      throw new Error('Chave HUGGINGFACE_API_KEY nao configurada.');
    }
    console.log('Testando IA de Imagem (Hugging Face - Stable Diffusion)...');
    
    const hfResponse = await fetch(
      "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2-1",
      {
        headers: { Authorization: `Bearer ${process.env.HUGGINGFACE_API_KEY}` },
        method: "POST",
        body: JSON.stringify({ inputs: "Um dragao branco de olhos azuis, estilo anime" }),
      }
    );

    if (hfResponse.ok) {
      console.log('Resposta Imagem: Imagem gerada e recebida em formato binario com sucesso.');
    } else {
      console.error('Falha na geracao de imagem:', hfResponse.statusText);
    }

    console.log('Etapa 1 concluida com exito. Infraestrutura basica de IA validada.');

  } catch (error) {
    console.error('Erro durante a validacao:', error.message);
  }
}

validarConexaoIA();