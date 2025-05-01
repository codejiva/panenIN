const { GoogleGenerativeAI } = require('@google/generative-ai');
const config = require('./config'); // pastikan ini mengarah ke file yang punya geminiApiKey

const genAI = new GoogleGenerativeAI(config.geminiApiKey);

async function listModels() {
  const models = await genAI.listModels();
  console.log("Available models:");
  models.forEach((model) => console.log(model.name));
}

listModels().catch(console.error);
