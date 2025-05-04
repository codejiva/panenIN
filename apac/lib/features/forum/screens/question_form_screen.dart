import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/widgets/ForumPostCard.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({Key? key}) : super(key: key);

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreen();
}

class _QuestionFormScreen extends State<QuestionFormScreen> {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 40,
                        height: 40,
                        child:ElevatedButton(
                            onPressed: () => context.goNamed('forum'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: CircleBorder(),
                              padding: EdgeInsets.zero,
                              elevation: 4,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 12,
                              color: Colors.white,)
                        )
                    ),
                    SizedBox(width: 10),
                    Expanded(  // Add Expanded to allow text to wrap
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
                              style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          Text(
                            'Question from: Fa***n',
                            style: GoogleFonts.sora(
                                fontSize: 10,
                                fontWeight: FontWeight.w300
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
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
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF7F7F7),
                            ),                          ),
                          SizedBox(height: 20,),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF7F7F7),
                            ),                          )

                        ],
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