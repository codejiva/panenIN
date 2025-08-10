import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/province_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Login controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // State variables
  bool _obscureText = true;
  bool _obscureLoginText = true;
  bool _privacyPolicyChecked = false;
  bool _isLoading = false;
  bool _isLoadingProvinces = false;
  bool _isLoginLoading = false;
  bool _isAuthenticating = false; // untuk auto login check
  String? _selectedProvince;
  List<Province> _provinces = [];

  // Auth state
  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _userData;

  // Constants for SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Getters
  bool get obscureText => _obscureText;
  bool get obscureLoginText => _obscureLoginText;
  bool get privacyPolicyChecked => _privacyPolicyChecked;
  bool get isLoading => _isLoading;
  bool get isLoadingProvinces => _isLoadingProvinces;
  bool get isLoginLoading => _isLoginLoading;
  bool get isAuthenticating => _isAuthenticating;
  bool get isLoggedIn => _isLoggedIn;
  String? get selectedProvince => _selectedProvince;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  List<Province> get provinces => _provinces;

  // Initialize - check if user already logged in
  Future<void> initializeAuth() async {
    _isAuthenticating = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      _token = prefs.getString(_tokenKey);
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null && userDataString.isNotEmpty) {
        try {
          _userData = json.decode(userDataString);
        } catch (e) {
          print('Error parsing user data: $e');
          _userData = null;
        }
      }

      // Validasi sederhana: jika ada token dan isLoggedIn true, anggap user masih login
      if (_token != null && _token!.isNotEmpty && _isLoggedIn) {
        _isLoggedIn = true;
        print('User found in storage - auto login successful');
      } else {
        // Jika tidak ada token atau data tidak lengkap, clear semua
        await _clearAuthData();
        print('No valid auth data found - user needs to login');
      }

    } catch (e) {
      print('Error initializing auth: $e');
      await _clearAuthData();
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> responseData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ambil token dari response (sesuaikan dengan struktur API Anda)
      _token = responseData['token'] ??
          responseData['access_token'] ??
          responseData['data']?['token'] ??
          responseData['accessToken'];

      _userData = responseData['user'] ??
          responseData['data'] ??
          responseData;

      // PENTING: Pastikan token tidak null sebelum menyimpan
      if (_token != null && _token!.isNotEmpty) {
        _isLoggedIn = true;

        await prefs.setString(_tokenKey, _token!);
        await prefs.setString(_userDataKey, json.encode(_userData));
        await prefs.setBool(_isLoggedInKey, true);

        print('Auth data saved successfully');
        print('Token: ${_token!.substring(0, 10)}...');
      } else {
        print('Warning: Token is null or empty, cannot save auth data');
        print('Response data keys: ${responseData.keys.toList()}');
        await _clearAuthData();
        throw Exception('Token tidak ditemukan dalam response');
      }

      notifyListeners();
    } catch (e) {
      print('Error saving auth data: $e');
      await _clearAuthData();
      rethrow;
    }
  }

  // Clear auth data from SharedPreferences
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_isLoggedInKey);

      _token = null;
      _userData = null;
      _isLoggedIn = false;

      print('Auth data cleared');
      notifyListeners();
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Langsung clear data lokal tanpa memanggil API logout
      await _clearAuthData();
      _clearLoginForm();

      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();

      // Navigate to login page
      if (context.mounted) {
        context.goNamed('login');
      }
    }
  }


  // Setters
  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void toggleLoginPasswordVisibility() {
    _obscureLoginText = !_obscureLoginText;
    notifyListeners();
  }

  void setPrivacyPolicyChecked(bool? value) {
    _privacyPolicyChecked = value ?? false;
    notifyListeners();
  }

  void setSelectedProvince(String? value) {
    _selectedProvince = value;
    notifyListeners();
  }

  // Method untuk login dengan email atau username
  Future<void> signIn(BuildContext context) async {
    if (!_validateLoginInput(context)) return;

    _isLoginLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://panen-in-teal.vercel.app/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'identifier': loginEmailController.text.trim(),
          'password': loginPasswordController.text.trim(),
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Simpan token dan data user
        await _saveAuthData(responseData);

        _showSuccessDialog(context, 'Login berhasil!', isLogin: true);
      } else {
        // Login gagal
        final responseData = json.decode(response.body);
        String errorMessage = 'Login gagal';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['error'] != null) {
          errorMessage = responseData['error'];
        }

        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan jaringan. Silakan coba lagi.');
      print('Login error: $e');
    } finally {
      _isLoginLoading = false;
      notifyListeners();
    }
  }

  // Validasi input login
  bool _validateLoginInput(BuildContext context) {
    if (loginEmailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Email atau username tidak boleh kosong');
      return false;
    }

    if (loginPasswordController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Password tidak boleh kosong');
      return false;
    }

    return true;
  }

  // Method untuk fetch provinsi dari API Indonesia
  Future<void> fetchProvinces() async {
    if (_provinces.isNotEmpty) return; // Sudah di-fetch sebelumnya

    _isLoadingProvinces = true;
    notifyListeners();

    try {
      // Menggunakan API wilayah Indonesia yang gratis
      final response = await http.get(
        Uri.parse('https://wilayah.id/api/provinces.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _provinces = data.map((json) => Province.fromJson(json)).toList();
      } else {
        // Fallback ke daftar provinsi statis jika API gagal
        _provinces = _getStaticProvinces();
      }
    } catch (e) {
      // Fallback ke daftar provinsi statis jika terjadi error
      _provinces = _getStaticProvinces();
      print('Error fetching provinces: $e');
    } finally {
      _isLoadingProvinces = false;
      notifyListeners();
    }
  }

  // Daftar provinsi statis sebagai fallback
  List<Province> _getStaticProvinces() {
    final provinceNames = [
      'Aceh',
      'Sumatera Utara',
      'Sumatera Barat',
      'Riau',
      'Kepulauan Riau',
      'Jambi',
      'Sumatera Selatan',
      'Bangka Belitung',
      'Bengkulu',
      'Lampung',
      'DKI Jakarta',
      'Jawa Barat',
      'Jawa Tengah',
      'DI Yogyakarta',
      'Jawa Timur',
      'Banten',
      'Bali',
      'Nusa Tenggara Barat',
      'Nusa Tenggara Timur',
      'Kalimantan Barat',
      'Kalimantan Tengah',
      'Kalimantan Selatan',
      'Kalimantan Timur',
      'Kalimantan Utara',
      'Sulawesi Utara',
      'Sulawesi Tengah',
      'Sulawesi Selatan',
      'Sulawesi Tenggara',
      'Gorontalo',
      'Sulawesi Barat',
      'Maluku',
      'Maluku Utara',
      'Papua Barat',
      'Papua',
      'Papua Tengah',
      'Papua Pegunungan',
      'Papua Selatan',
      'Papua Barat Daya'
    ];

    return provinceNames.asMap().entries.map((entry) =>
        Province(name: entry.value)
    ).toList();
  }

  // Method untuk signup
  Future<void> signUp(BuildContext context) async {
    // Validasi input
    if (!_validateInput(context)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://panen-in-teal.vercel.app/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'region': _selectedProvince,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Signup berhasil
        _showSuccessDialog(context, 'Akun berhasil dibuat!');
      } else {
        // Signup gagal
        final responseData = json.decode(response.body);
        String errorMessage = 'Signup gagal';

        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['error'] != null) {
          errorMessage = responseData['error'];
        }

        _showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan jaringan. Silakan coba lagi.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validasi input signup
  bool _validateInput(BuildContext context) {
    if (nameController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Nama tidak boleh kosong');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Email tidak boleh kosong');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _showErrorDialog(context, 'Format email tidak valid');
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showErrorDialog(context, 'Password tidak boleh kosong');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showErrorDialog(context, 'Password minimal 6 karakter');
      return false;
    }

    if (_selectedProvince == null || _selectedProvince!.isEmpty) {
      _showErrorDialog(context, 'Silakan pilih provinsi');
      return false;
    }

    if (!_privacyPolicyChecked) {
      _showErrorDialog(context, 'Anda harus menyetujui Privacy Policy');
      return false;
    }

    return true;
  }

  // Validasi email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog
  void _showSuccessDialog(BuildContext context, String message, {bool isLogin = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Berhasil'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isLogin) {
                  // Clear login form
                  _clearLoginForm();
                  // Navigate to dashboard
                  context.goNamed('home');
                } else {
                  // Clear signup form
                  _clearForm();
                  // Navigate to login page
                  context.pushNamed('login');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Clear signup form
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    _selectedProvince = null;
    _privacyPolicyChecked = false;
    _obscureText = true;
    notifyListeners();
  }

  // Clear login form
  void _clearLoginForm() {
    loginEmailController.clear();
    loginPasswordController.clear();
    _obscureLoginText = true;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }
}