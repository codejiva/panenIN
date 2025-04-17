import 'package:flutter/material.dart';
import '../../../config/constants/colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/social_button.dart';
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
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
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
                  )),
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
                Text('data'),
                SizedBox(height: 50,),
                Container(
                  child: Column(
                    children:[
                      TextField(
                        decoration: InputDecoration(
                            labelText: 'Nama'
                        ),
                      ),
                      SizedBox(height: 25),
                      TextField(
                        decoration: InputDecoration(
                            labelText: 'Email'
                        ),
                      ),
                      SizedBox(height: 25),
                      TextField(
                        decoration: InputDecoration(
                            labelText: 'Email'
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}