import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/widgets/ForumPostCard.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Community Forum',
                              style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          Text(
                              'Where Ideas Grow and Connections Matter!',
                              style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w300
                              )
                          ),
                        ],
                      ),
                      ),
                      SizedBox(
                        width: 66,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => context.goNamed('signup'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Buat padding button pas dengan size kecil
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/images/Edit.svg'),
                              SizedBox(width: 4), // kasih jarak sedikit antar ikon dan teks
                              Text(
                                'Ask',
                                style: GoogleFonts.sora(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                )
              ],
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}