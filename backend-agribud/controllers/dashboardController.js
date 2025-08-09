const pool = require('../config/db');
const Groq = require('groq-sdk'); // 1. Import library Groq

// 2. Inisialisasi Groq dengan API key baru
const groq = new Groq({
  apiKey: process.env.GROQ_API_KEY,
});

// Mendapatkan ringkasan terakhir dari DB
exports.getLatestSummary = async (req, res) => {
  try {
    const sql = 'SELECT * FROM daily_summaries ORDER BY summary_date DESC LIMIT 1';
    const [rows] = await pool.query(sql);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'No summary available yet. Please generate one first.' });
    }
    res.status(200).json(rows[0]);
  } catch (error) {
    console.error("Error fetching latest summary:", error);
    res.status(500).json({ message: 'Server error.' });
  }
};

// Membuat ringkasan harian baru menggunakan Groq
exports.generateDailySummary = async (req, res) => {
  try {
    // Simulasi data rata-rata harian
    const avgData = {
      temperature: (Math.random() * 5 + 26).toFixed(2),
      humidity: (Math.random() * 15 + 65).toFixed(2),
      ph: (Math.random() * 0.5 + 6.0).toFixed(2),
      light_intensity: Math.floor(Math.random() * 2000 + 12000)
    };

    // Prompt tetap sama, tapi kita perintahkan AI untuk merespons dalam format JSON
    const prompt = `
      Anda adalah seorang ahli agronomi. Berdasarkan data sensor harian dari sebuah kebun cabai berikut:
      - Rata-rata Suhu: ${avgData.temperature}°C
      - Rata-rata Kelembapan: ${avgData.humidity}%
      - Rata-rata pH Tanah: ${avgData.ph}
      - Rata-rata Intensitas Cahaya: ${avgData.light_intensity} lux

      Berikan analisis dalam format JSON. JANGAN tambahkan markdown atau teks lain di luar JSON.
      Isi "plant_status" dengan 1-3 kata (contoh: "Tumbuh Optimal", "Sedikit Stres Panas", "Risiko Jamur").
      Isi "diagnosis" dengan penjelasan singkat (1-2 kalimat) mengenai kondisi saat ini.
      Isi "recommendation" dengan 1-2 tindakan konkret yang bisa dilakukan petani.
    `;

    // 3. Panggil API Groq dengan model Llama 3
    const chatCompletion = await groq.chat.completions.create({
      messages: [{ role: 'user', content: prompt }],
      model: 'llama3-8b-8192', // Model yang cepat dan cerdas
      temperature: 0.7,
      response_format: { type: 'json_object' }, // Memaksa output menjadi JSON
    });

    const responseContent = chatCompletion.choices[0]?.message?.content;
    if (!responseContent) {
        throw new Error("AI did not return a valid response.");
    }
    
    const analysis = JSON.parse(responseContent);

    // Simpan hasilnya ke database (logika ini tidak berubah)
    const today = new Date().toISOString().slice(0, 10);
    const sql = `
      INSERT INTO daily_summaries (summary_date, avg_temperature, avg_humidity, avg_ph, avg_light_intensity, plant_status, diagnosis, recommendation)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
      avg_temperature = VALUES(avg_temperature), avg_humidity = VALUES(avg_humidity), avg_ph = VALUES(avg_ph),
      avg_light_intensity = VALUES(avg_light_intensity), plant_status = VALUES(plant_status),
      diagnosis = VALUES(diagnosis), recommendation = VALUES(recommendation);
    `;
    
    await pool.query(sql, [
      today, avgData.temperature, avgData.humidity, avgData.ph,
      avgData.light_intensity, analysis.plant_status, analysis.diagnosis, analysis.recommendation
    ]);

    res.status(201).json({ message: 'Daily summary generated successfully with Groq.', data: analysis });

  } catch (error) {
    console.error("Error generating daily summary with Groq:", error);
    res.status(500).json({ message: 'Server error or error communicating with AI model.' });
  }
};
