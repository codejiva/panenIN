class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://panen-in-teal.vercel.app/api';

  // Google Maps API Key
  static const String googleMapsApiKey = '';

  // Auth Endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String verifyTokenEndpoint = '$baseUrl/auth/verify';
  static const String logoutEndpoint = '$baseUrl/auth/logout';

  // Indonesia Provinces API
  static const String provincesApiUrl = 'https://wilayah.id/api/provinces.json';

  // SharedPreferences Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Info
  static const String appName = 'Panen In';
  static const String appTagline = 'Solusi Pertanian Modern';
  static const String appVersion = '1.0.0';

  // Default Map Configuration
  static const double defaultMapZoom = 14.0;

  // Sensor Thresholds
  static const Map<String, Map<String, double>> sensorThresholds = {
    'temperature': {
      'min': 20.0,
      'max': 30.0,
    },
    'soilMoisture': {
      'min': 30.0,
      'max': 70.0,
    },
    'soilPH': {
      'min': 6.0,
      'max': 6.8,
    },
    'lightIntensity': {
      'min': 60.0,
      'max': 90.0,
    },
  };
}