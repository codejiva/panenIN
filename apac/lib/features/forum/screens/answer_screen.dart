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
          cornerColor:AppColors.secondary
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
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Date: ',
                                  style: GoogleFonts.sora(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
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
                        ],
                      ),
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
                            SizedBox(height: 10),
                            Text(
                                'Answered by: Dr. Agr. Siti Maesaroh',
                                style: GoogleFonts.sora(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                )
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,  // Align items to the top
                              children: [
                                SvgPicture.asset('assets/images/wheat.svg'),
                                SizedBox(width: 8),  // Add some spacing
                                Expanded(  // Add Expanded to allow text to wrap
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Answered by: Dr. Agr. Siti Maesaroh',
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12
                                          )
                                      ),
                                      Text(
                                        'AgriDoctor, I often hear about using soil moisture sensors '
                                            'in smart farming. Is it true that these devices can help '
                                            'improve plant growth and crop yields? How exactly do '
                                            'they work, and are there any tips for using them '
                                            'effectively?',
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                            Divider(
                              thickness: 0.75,
                              color: Colors.black,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,  // Align items to the top
                              children: [
                                SvgPicture.asset('assets/images/Check_ring.svg'),
                                SizedBox(width: 8),  // Add some spacing
                                Expanded(  // Add Expanded to allow text to wrap
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Doctor's Answer:",
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12
                                          )
                                      ),
                                      Text(
                                          "Responded by: Dr. Agr. Siti Maesaroh",
                                          style: GoogleFonts.sora(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10
                                          )
                                      ),
                                      Text(
                                          "Date: April 26, 2025 | Time: 21:15",
                                          style: GoogleFonts.sora(
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10
                                          )
                                      ),
                                      Text(
                                        'Hello, good evening,\n\n'
                                            'Soil moisture sensors are devices that measure the water content in the soil. They play an important role in modern agriculture by providing real-time data on soil moisture levels. Here are some benefits of using them:\n'
                                            '• Optimizing irrigation: Ensures plants receive the right amount of water — not too much, not too little.\n'
                                            '• Improving plant health: Proper watering helps in better root development and overall plant growth.\n'
                                            '• Increasing crop yields: Healthier plants lead to more productive harvests.\n'
                                            '• Saving water: By avoiding over-irrigation, you can conserve water and reduce costs.\n\n'
                                            'How They Work: Soil moisture sensors typically use electrical resistance or dielectric properties to detect the amount of moisture present. They send signals that can be read manually or integrated into automatic irrigation systems.\n\n'
                                            'Tips for Using Them Effectively:\n'
                                            '• Place sensors at different depths to monitor moisture throughout the root zone.\n'
                                            '• Regularly calibrate the sensors for accuracy.\n'
                                            '• Combine soil moisture readings with weather data for better irrigation planning.\n'
                                            '• Start with a trial area before deploying widely across your farm.\n\n'
                                            'Using soil moisture sensors wisely can significantly support smart farming practices, making agriculture more efficient and sustainable.\n'
                                            'Hope this helps and good luck with your planting!',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
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