import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/constants/colors.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _provinceSearchController = TextEditingController();
  List<dynamic> _filteredProvinces = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    // Fetch provinces when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchProvinces().then((_) {
        setState(() {
          _filteredProvinces = authProvider.provinces;
        });
      });
    });
  }

  @override
  void dispose() {
    _provinceSearchController.dispose();
    super.dispose();
  }

  void _filterProvinces(String query, AuthProvider provider) {
    setState(() {
      if (query.isEmpty) {
        _filteredProvinces = provider.provinces;
      } else {
        _filteredProvinces = provider.provinces
            .where((province) =>
            province.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildGoogleButton(provider),
                      const SizedBox(height: 30),
                      Text(
                        'OR SIGN UP WITH EMAIL',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      _buildForm(provider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/images/headerauth.png', fit: BoxFit.contain),
        Text(
          'Welcome AgriHero!',
          style: GoogleFonts.montserrat(
              fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 20),
              padding: EdgeInsets.zero,
              onPressed: () => context.go('/'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(AuthProvider provider) {
    return ElevatedButton(
      onPressed: provider.isLoading
          ? null
          : () {
        // TODO: Implement Google Sign Up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign Up will be implemented soon'),
            backgroundColor: Colors.orange,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(374, 63),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: const BorderSide(color: Colors.grey, width: 0.2),
        ),
        elevation: 1,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/googlelogo.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.g_mobiledata, size: 24);
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'CONTINUE WITH GOOGLE',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildForm(AuthProvider provider) {
    return Column(
      children: [
        // Name Field
        TextField(
          controller: provider.nameController,
          enabled: !provider.isLoading,
          decoration: _inputDecoration('Full Name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 25),

        // Email Field
        TextField(
          controller: provider.emailController,
          enabled: !provider.isLoading,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 25),

        // Password Field
        TextField(
          controller: provider.passwordController,
          enabled: !provider.isLoading,
          obscureText: provider.obscureText,
          decoration: _inputDecoration('Password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed:
              provider.isLoading ? null : provider.togglePasswordVisibility,
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 25),

        // Province Dropdown
        _buildSearchableProvinceDropdown(provider),
        const SizedBox(height: 20),

        // Privacy Policy Checkbox
        _buildPrivacyPolicyRow(provider),
        const SizedBox(height: 30),

        // Sign Up Button
        _buildSignUpButton(provider),

        const SizedBox(height: 20),

        // Login Link
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildSearchableProvinceDropdown(AuthProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: provider.isLoadingProvinces || provider.isLoading
              ? null
              : () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: _isDropdownOpen ? AppColors.primary : Colors.grey[300]!,
                width: _isDropdownOpen ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.selectedProvince ?? 'Select Province',
                    style: GoogleFonts.inter(
                      color: provider.selectedProvince != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                if (provider.isLoadingProvinces)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
        ),

        // Dropdown Menu
        if (_isDropdownOpen && !provider.isLoadingProvinces)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _provinceSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search province...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) => _filterProvinces(value, provider),
                  ),
                ),

                // Province List
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredProvinces.length,
                    itemBuilder: (context, index) {
                      final province = _filteredProvinces[index];
                      final isSelected =
                          provider.selectedProvince == province.name;

                      return InkWell(
                        onTap: () {
                          provider.setSelectedProvince(province.name);
                          setState(() {
                            _isDropdownOpen = false;
                            _provinceSearchController.clear();
                            _filteredProvinces = provider.provinces;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  province.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // No results message
                if (_filteredProvinces.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Province not found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyPolicyRow(AuthProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: provider.privacyPolicyChecked,
          onChanged: provider.isLoading ? null : provider.setPrivacyPolicyChecked,
          activeColor: AppColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: provider.isLoading
                ? null
                : () {
              provider.setPrivacyPolicyChecked(
                  !provider.privacyPolicyChecked);
            },
            child: RichText(
              text: TextSpan(
                text: 'I have read and agree to the ',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AuthProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => provider.signUp(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF307D32),
          disabledBackgroundColor: Colors.grey[300],
          minimumSize: const Size(double.infinity, 63),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 2,
        ),
        child: provider.isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          "Get Started",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "ALREADY HAVE AN ACCOUNT? ",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () => context.goNamed('login'),
          child: Text(
            'SIGN IN',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        color: Colors.grey[600],
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}