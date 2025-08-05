import 'dart:io';
import 'package:flutter/services.dart';
import '../../../config/constants/constants.dart';

class GoogleMapsService {
  static bool _isInitialized = false;

  /// Initialize Google Maps with API key from constants
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set API key untuk Android
      if (Platform.isAndroid) {
        await _setAndroidApiKey();
      }

      // Set API key untuk iOS
      if (Platform.isIOS) {
        await _setIOSApiKey();
      }

      _isInitialized = true;
      print('Google Maps initialized successfully');
    } catch (e) {
      print('Error initializing Google Maps: $e');
      throw Exception('Failed to initialize Google Maps: $e');
    }
  }

  /// Set API key untuk Android menggunakan platform channel
  static Future<void> _setAndroidApiKey() async {
    const platform = MethodChannel('com.example.panenin/google_maps');

    try {
      await platform.invokeMethod('setApiKey', {
        'apiKey': AppConstants.googleMapsApiKey,
      });
    } catch (e) {
      print('Error setting Android API key: $e');
      // Fallback: gunakan cara lama jika method channel tidak tersedia
      // Dalam kasus ini, Anda tetap perlu menggunakan AndroidManifest.xml
    }
  }

  /// Set API key untuk iOS menggunakan platform channel
  static Future<void> _setIOSApiKey() async {
    const platform = MethodChannel('com.example.panenin/google_maps');

    try {
      await platform.invokeMethod('setApiKey', {
        'apiKey': AppConstants.googleMapsApiKey,
      });
    } catch (e) {
      print('Error setting iOS API key: $e');
      // Fallback: gunakan Info.plist jika method channel tidak tersedia
    }
  }

  /// Get API key (untuk digunakan dalam widget atau API calls lainnya)
  static String getApiKey() {
    return AppConstants.googleMapsApiKey;
  }

  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    // Google Maps API key biasanya dimulai dengan "AIza" dan memiliki panjang tertentu
    return apiKey.isNotEmpty &&
        apiKey.startsWith('AIza') &&
        apiKey.length > 30;
  }

  /// Check if Google Maps is properly initialized
  static bool get isInitialized => _isInitialized;
}