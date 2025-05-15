#include <Arduino.h>
#include <LiquidCrystal_I2C.h> // Untuk LCD
#include <Servo.h>

// Inisialisasi LCD (sesuaikan alamat I2C)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Pin Sensor
#define LM35_PIN A0
#define PIR_PIN 7
#define PH_PIN A1
#define LDR_PIN A2
#define SERVO_PIN 10

Servo myServo;

// Deklarasi fungsi
float bacaSuhu();
int bacaCahaya();
float bacaPH();
void tampilLCD(float suhu, int cahaya, float ph);
void kirimSerial(float suhu, int cahaya, float ph);

void setup()
{
    Serial.begin(9600);

    // Inisialisasi LCD
    lcd.init();
    lcd.backlight();
    lcd.print("AgriBud System");

    // Setup pin servo (meski tidak dipakai, tetap diinit untuk konsistensi)
    myServo.attach(SERVO_PIN);

    delay(2000);
    lcd.clear();
}

void loop()
{
    // Baca sensor
    float suhu = bacaSuhu();
    int cahaya = bacaCahaya();
    float ph = bacaPH();

    // Tampilkan di LCD
    tampilLCD(suhu, cahaya, ph);

    // Kirim data ke Serial (Node.js)
    kirimSerial(suhu, cahaya, ph);

    delay(3000); // Sesuai interval backend
}

// Implementasi fungsi
float bacaSuhu()
{
    return analogRead(LM35_PIN) * 0.48876; // Konversi ke Celsius
}

int bacaCahaya()
{
    return map(analogRead(LDR_PIN), 0, 1023, 0, 15000); // Konversi ke lux
}

float bacaPH()
{
    // Simulasi pH dengan potensiometer
    return map(analogRead(PH_PIN), 0, 1023, 45, 85) / 10.0; // Hasil 4.5 - 8.5
}

void tampilLCD(float suhu, int cahaya, float ph)
{
    lcd.setCursor(0, 0);
    lcd.print("S:");
    lcd.print(suhu, 1); // 1 digit desimal
    lcd.print("C L:");
    lcd.print(cahaya / 1000);
    lcd.print("k");

    lcd.setCursor(0, 1);
    lcd.print("pH:");
    lcd.print(ph, 1); // 1 digit desimal
}

void kirimSerial(float suhu, int cahaya, float ph)
{
    Serial.print("AGRIBUD_DATA:");
    Serial.print(suhu);
    Serial.print(",");
    Serial.print(cahaya);
    Serial.print(",");
    Serial.println(ph); // Gunakan println untuk data terakhir
}