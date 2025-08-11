class DashboardData {
  final int id;
  final DateTime summaryDate;
  final double temperature;
  final double humidity;
  final double soilPH;
  final double lightIntensity;
  final String plantStatus;
  final String diagnosis;
  final String recommendation;
  final DateTime createdAt;

  DashboardData({
    required this.id,
    required this.summaryDate,
    required this.temperature,
    required this.humidity,
    required this.soilPH,
    required this.lightIntensity,
    required this.plantStatus,
    required this.diagnosis,
    required this.recommendation,
    required this.createdAt,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      id: json['id'],
      summaryDate: DateTime.parse(json['summary_date']),
      temperature: double.parse(json['avg_temperature']),
      humidity: double.parse(json['avg_humidity']),
      soilPH: double.parse(json['avg_ph']),
      lightIntensity: json['avg_light_intensity'].toDouble(),
      plantStatus: json['plant_status'],
      diagnosis: json['diagnosis'],
      recommendation: json['recommendation'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Getter for timestamp compatibility with existing code
  DateTime get timestamp => createdAt;
}