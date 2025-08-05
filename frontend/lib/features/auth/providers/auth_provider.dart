import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/province_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State variables
  bool _obscureText = true;
  bool _privacyPolicyChecked = false;
  bool _isLoading = false;
  bool _isLoadingProvinces = false;
  String? _selectedProvince;
  List<Province> _provinces = [];

  // Getters
  bool get obscureText => _obscureText;
  bool get privacyPolicyChecked => _privacyPolicyChecked;
  bool get isLoading => _isLoading;
  bool get isLoadingProvinces => _isLoadingProvinces;
  String? get selectedProvince => _selectedProvince;
  List<Province> get provinces => _provinces;

  // Setters
  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
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
      print('Signup error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validasi input
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
  void _showSuccessDialog(BuildContext context, String message) {
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
                // Clear form
                _clearForm();
                // Navigate to login page
                context.pushNamed('login');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    _selectedProvince = null;
    _privacyPolicyChecked = false;
    _obscureText = true;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}