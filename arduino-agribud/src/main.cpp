#include <Arduino.h>
#include <LiquidCrystal_I2C.h> // Untuk LCD

// Inisialisasi LCD (sesuaikan alamat I2C)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Pin Sensor
#define LM35_PIN A0
#define PIR_PIN 7
#define PH_PIN A1
#define LDR_PIN A2
#define ULTRASONIC_TRIG 8
#define ULTRASONIC_ECHO 9
#define SERVO_PIN 10

Servo myServo;

void setup()
{
    Serial.begin(9600);

    // Inisialisasi LCD
    lcd.init();
    lcd.backlight();
    lcd.print("AgriBud System");

    // Setup pin
    pinMode(PIR_PIN, INPUT);
    pinMode(ULTRASONIC_TRIG, OUTPUT);
    pinMode(ULTRASONIC_ECHO, INPUT);
    myServo.attach(SERVO_PIN);

    delay(2000);
    lcd.clear();
}

void loop()
{
    // sensor
    float suhu = bacaSuhu();
    int cahaya = bacaCahaya();
    float ph = bacaPH();

    // Tampilin di LCD
    tampilLCD(suhu, cahaya, ph);

    // kirim ke serial nodejs yang gue puynya
    kirimSerial(suhu, cahaya, ph);

    delay(3000); // Sesuai interval backend
}

// func buat sensor2nya
float bacaSuhu()
{
    return analogRead(LM35_PIN) * 0.48876;
}

int bacaCahaya()
{
    return map(analogRead(LDR_PIN), 0, 1023, 0, 15000);
}

float bacaPH()
{
    // simulasi pH
    return map(analogRead(PH_PIN), 0, 1023, 45, 85) / 10.0;
}



// fun buat lcd
void tampilLCD(float suhu, int cahaya, float ph)
{
    lcd.setCursor(0, 0);
    lcd.print("S:");
    lcd.print(suhu);
    lcd.print("C L:");
    lcd.print(cahaya / 1000);
    lcd.print("k");

    lcd.setCursor(0, 1);
    lcd.print("pH:");
    lcd.print(ph);
    lcd.print(" J:");
    lcd.print("cm");
}

// fun buat kirim ke serialnya
void kirimSerial(float suhu, int cahaya, float ph)
{
    Serial.print("AGRIBUD_DATA:");
    Serial.print(suhu);
    Serial.print(",");
    Serial.print(cahaya);
    Serial.print(",");
    Serial.print(ph);
}