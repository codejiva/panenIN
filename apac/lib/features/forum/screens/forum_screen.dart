import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:PanenIn/features/forum/widgets/ForumPostCard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            ForumPostCard(
              question: 'What Are the Benefits of Using Soil Moisture Sensors for Plant Growth?',
              author: 'Pa***n',
              expertName: 'Dr. Agr. Siti Masaroh',
              commentCount: 0,
            ),
            SizedBox(height: 16),
            ForumPostCard(
              question: 'How Can Spraying Drones Help Farmers During Planting Season?',
              author: 'Al***n',
              expertName: 'Eng. Budi Santoso, M.Sc',
              commentCount: 0,
            ),
            SizedBox(height: 16),
            ForumPostCard(
              question: 'Can IoT in Livestock Farming Detect Diseases Faster?',
              author: 'De***i',
              expertName: 'Drh. Lilis Suryani',
              commentCount: 0,
            ),
          ],
        ),
      ),
    );
  }
}