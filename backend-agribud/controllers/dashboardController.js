const pool = require('../config/db');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

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

// Membuat ringkasan harian baru
exports.generateDailySummary = async (req, res) => {
  try {
    // 1. Simulasi data rata-rata harian (nanti bisa diganti data asli)
    const avgData = {
      temperature: (Math.random() * 5 + 26).toFixed(2), // 26-31°C
      humidity: (Math.random() * 15 + 65).toFixed(2),    // 65-80%
      ph: (Math.random() * 0.5 + 6.0).toFixed(2),        // 6.0-6.5
      light_intensity: Math.floor(Math.random() * 2000 + 12000) // 12000-14000 lux
    };

    // 2. Buat prompt untuk Gemini agar mengembalikan JSON
    const prompt = `
      Anda adalah seorang ahli agronomi. Berdasarkan data sensor harian dari sebuah kebun cabai berikut:
      - Rata-rata Suhu: ${avgData.temperature}°C
      - Rata-rata Kelembapan: ${avgData.humidity}%
      - Rata-rata pH Tanah: ${avgData.ph}
      - Rata-rata Intensitas Cahaya: ${avgData.light_intensity} lux

      Berikan analisis dalam format JSON. JANGAN tambahkan markdown atau teks lain di luar JSON. Formatnya harus seperti ini:
      {
        "plant_status": "...",
        "diagnosis": "...",
        "recommendation": "..."
      }

      Isi "plant_status" dengan 1-3 kata (contoh: "Tumbuh Optimal", "Sedikit Stres Panas", "Risiko Jamur").
      Isi "diagnosis" dengan penjelasan singkat (1-2 kalimat) mengenai kondisi saat ini.
      Isi "recommendation" dengan 1-2 tindakan konkret yang bisa dilakukan petani.
    `;

    // 3. Panggil API Gemini
    const result = await model.generateContent(prompt);
    const responseText = result.response.text();
    
    // Membersihkan output dari Gemini jika ada markdown
    const cleanedText = responseText.replace(/```json/g, '').replace(/```/g, '');
    const analysis = JSON.parse(cleanedText);

    // 4. Simpan hasilnya ke database
    const today = new Date().toISOString().slice(0, 10);
    const sql = `
      INSERT INTO daily_summaries (summary_date, avg_temperature, avg_humidity, avg_ph, avg_light_intensity, plant_status, diagnosis, recommendation)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
      avg_temperature = VALUES(avg_temperature),
      avg_humidity = VALUES(avg_humidity),
      avg_ph = VALUES(avg_ph),
      avg_light_intensity = VALUES(avg_light_intensity),
      plant_status = VALUES(plant_status),
      diagnosis = VALUES(diagnosis),
      recommendation = VALUES(recommendation);
    `;
    
    await pool.query(sql, [
      today,
      avgData.temperature,
      avgData.humidity,
      avgData.ph,
      avgData.light_intensity,
      analysis.plant_status,
      analysis.diagnosis,
      analysis.recommendation
    ]);

    res.status(201).json({ message: 'Daily summary generated successfully.', data: analysis });

  } catch (error) {
    console.error("Error generating daily summary:", error);
    res.status(500).json({ message: 'Server error or error communicating with AI model.' });
  }
};
