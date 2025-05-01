import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({Key? key}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreen();
}

class _AnswerScreen extends State<AnswerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {
          print('Notifikasi ditekan dari HomeScreen!');
          // Tambahkan aksi khusus untuk notifikasi di halaman ini
        },
        onProfilePressed: () {
          print('Profile ditekan dari HomeScreen!');
          // Tambahkan aksi khusus untuk profile di halaman ini
        },
      ),
      body: Container(
        color: AppColors.secondary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'What Are the Benefits of Using Soil Moisture',
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      Text(
                          'Sensors for Plant Growth?',                       style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      )
                      ),
                      Text(
                        'Question from: Fa***n',
                        style: GoogleFonts.sora(
                            fontSize: 10,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Date: ',
                              style: GoogleFonts.sora(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            TextSpan(
                              text: 'April 26, 2025',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12
                              ),
                            ),
                            TextSpan(
                              text: ' | ',
                            ),
                            TextSpan(
                              text: 'Time: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                            TextSpan(
                              text: '18:30',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [

                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 4,
                      offset: Offset(0, -3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10,),
                          Text(
                            'Answered by: Dr. Agr. Siti Maesaroh',
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            )
                          )
                      ],
                    ),
                  )
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}