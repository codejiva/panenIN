import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Frame oke.png',
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                    'Real-Time Monitoring',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700
                    )),
                Text(
                    'for Smarter Farming',
                    style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w700
                    )),
                Text(
                    'Start your smarter farming journey with technology',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF307D32),
                        fontWeight: FontWeight.w300
                    )),
                SizedBox(height: 80),
                Container(
                  width: 374,
                  height: 63,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFF307D32),
                    borderRadius: BorderRadius.circular(32)
                  ),
                  child: Text(
                      'Sign Up',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white
                      ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'ALREADY HAVE AN ACCOUNT?',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w300
                        )),
                    SizedBox(width: 10,),
                    Text(
                        'LOG IN',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF307D32),
                            fontWeight: FontWeight.w300
                        )),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }
}