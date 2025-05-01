import 'package:PanenIn/config/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForumPostCard extends StatelessWidget {
  final String question;
  final String author;
  final String expertName;
  final int commentCount;

  const ForumPostCard({
    Key? key,
    required this.question,
    required this.author,
    required this.expertName,
    this.commentCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
    InkWell(
        onTap: () => context.goNamed('answer'),
        child: Card(
      color: AppColors.tersier,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By: $author',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Answered by: $expertName',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 106,
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => context.goNamed('answer'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // ubah angka sesuai keinginan
                          ),
                          padding: EdgeInsets.zero, // Buat padding button pas dengan size kecil
                          backgroundColor: Colors.white
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              'assets/images/Edit.svg',
                              color: AppColors.textPrimary
                          ),
                          SizedBox(width: 4), // kasih jarak sedikit antar ikon dan teks
                          Text(
                            'Comment',
                            style: GoogleFonts.sora(
                                fontSize: 13,
                                color: AppColors.textPrimary
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Divider(),
            )
          ],
        ),
      ),
    )
    );
  }
}