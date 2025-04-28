import 'package:flutter/material.dart';
import '../../../config/constants/colors.dart';
import '../../../shared/widgets/buttom_navbar.dart';
import '../providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _privacyPolicyChecked = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    bool isChecked = false;
    bool _obscureText = true;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      resizeToAvoidBottomInset: false,
      body:SingleChildScrollView(
        padding: EdgeInsets.only(bottom: isKeyboardOpen ? 280 : 0),
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
                        fontWeight: FontWeight.bold
                    )
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () => context.goNamed('signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: Size(374, 63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                          // ↓ Ini tambahan border-nya
                          side: BorderSide(
                            color: Colors.grey, // Warna border
                            width: 0.2,         // Ketebalan border
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                              'assets/images/googlelogo.png',
                              fit: BoxFit.cover
                          ),
                          Expanded(
                              child:
                              Container(
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
                          )
                        ],
                      )
                  ),
                  SizedBox(height: 30,),
                  Text(
                    'OR LOG IN WITH EMAIL',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 50,),
                  Container(
                    child: Column(
                      children:[
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Nama',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none
                              )
                          ),
                        ),
                        SizedBox(height: 25),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none
                              )
                          ),
                        ),
                        SizedBox(height: 25),
                        TextField(
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true, // Jika ingin background berwarna
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'i have read the ',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black54
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Privace Policy', // Diubah dari SIGN UP karena lebih sesuai dengan konteksnya
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.goNamed('home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF307D32),
                            minimumSize: Size(374, 63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Text(
                            "Get Started",
                            style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}