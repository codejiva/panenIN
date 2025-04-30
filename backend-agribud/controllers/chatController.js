const { GoogleGenerativeAI } = require('@google/generative-ai');
const config = require('../config');

// API key gue taro di config.js
const genAI = new GoogleGenerativeAI(config.geminiApiKey);

exports.chatWithGemini = async (req, res) => {
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({ message: 'Message is required' });
  }

  try {
    // kalo mau diubah, tolong masukin versi spesifiknya kyk di bawah
    const model = genAI.getGenerativeModel({
      model: "gemini-1.5-pro-latest", // npm baru bisa versi ini ya. jadi belum bisa pake yang 2.5
    });

    // baru bisa input text ya. belum bisa foto sama suara
    const result = await model.generateContent(message);
    const response = await result.response;
    const text = response.text();

    res.status(200).json({ reply: text });
  } catch (error) {
    console.error('Full error:', error);
    res.status(500).json({
      message: 'Error communicating with Gemini',
      error: error.message,
      solution: 'Check your API key and model name',
      workingModels: ['gemini-1.5-pro-latest', 'gemini-pro']
    });
  }
};