import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
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
              children: [
                Column(
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
                Expanded(child: ElevatedButton(
                    onPressed: () => context.goNamed('signup'),
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.edit)
                        ],
                      ),
                    )
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}