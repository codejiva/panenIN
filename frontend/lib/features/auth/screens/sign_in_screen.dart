import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/constants/colors.dart';
import '../../../shared/widgets/buttom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Listen untuk perubahan keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.addListener(_onFocusChange);
      _passwordFocusNode.addListener(_onFocusChange);
    });
  }

  void _onFocusChange() {
    // Delay sedikit untuk memastikan keyboard sudah muncul
    Future.delayed(Duration(milliseconds: 300), () {
      if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
        _scrollToActiveField();
      }
    });
  }

  void _scrollToActiveField() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // Scroll ke posisi yang memastikan field terlihat
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent * 0.6, // Scroll ke 60% dari max scroll
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: true, // Ubah ke true agar responsive terhadap keyboard
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // Dismiss keyboard saat scroll
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/headerauth.png',
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Welcome AgriHero!',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black54, size: 20),
                              padding: EdgeInsets.zero,
                              onPressed: () => context.goNamed('onboarding'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: authProvider.isLoginLoading ? null : () {
                                // TODO: Implement Google Sign In
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: Size(374, 63),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/googlelogo.png',
                                    fit: BoxFit.cover,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        'CONTINUE WITH GOOGLE',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Text(
                              'OR LOG IN WITH EMAIL',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 50),
                            Column(
                              children: [
                                TextField(
                                  controller: authProvider.loginEmailController,
                                  focusNode: _emailFocusNode,
                                  enabled: !authProvider.isLoginLoading,
                                  textInputAction: TextInputAction.next, // Tambahkan ini
                                  keyboardType: TextInputType.emailAddress, // Tambahkan ini untuk email
                                  onSubmitted: (value) {
                                    // Auto focus ke password field saat submit
                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email address or Username',
                                    hintText: 'Enter your email or username',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF7F7F7),
                                  ),
                                ),
                                SizedBox(height: 25),
                                TextField(
                                  controller: authProvider.loginPasswordController,
                                  focusNode: _passwordFocusNode,
                                  enabled: !authProvider.isLoginLoading,
                                  obscureText: authProvider.obscureLoginText,
                                  textInputAction: TextInputAction.done, // Tambahkan ini
                                  onSubmitted: (value) {
                                    // Auto login saat submit password
                                    if (!authProvider.isLoginLoading) {
                                      authProvider.signIn(context);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF7F7F7),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        authProvider.obscureLoginText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: authProvider.isLoginLoading
                                          ? null
                                          : authProvider.toggleLoginPasswordVisibility,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: authProvider.isLoginLoading
                                      ? null
                                      : () => authProvider.signIn(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF307D32),
                                    minimumSize: Size(374, 63),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  child: authProvider.isLoginLoading
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : Text(
                                    "LOG IN",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: authProvider.isLoginLoading ? null : () {
                                      // TODO: Add forgot password functionality
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 35),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "DON'T HAVE AN ACCOUNT? ",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: authProvider.isLoginLoading
                                          ? null
                                          : () => context.goNamed('signup'),
                                      child: Text(
                                        'SIGN UP',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}