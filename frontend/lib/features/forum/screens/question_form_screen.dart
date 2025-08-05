import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/forum/widgets/ForumPostCard.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreen();
}

class _QuestionFormScreen extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _topicController = TextEditingController(text: 'Agriculture');
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
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
                              color: Colors.white,
                            )
                        )
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Ask your question',
                              style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          Text(
                            'Feel free to start by asking your question.',
                            style: GoogleFonts.sora(
                                fontSize: 12,
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
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      children: [
                        // Topic Section
                        Text(
                          'Topic',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 8),
                        // Agriculture Input Field
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Agriculture',
                                style: GoogleFonts.sora(
                                    color: Colors.grey,
                                    fontSize: 16
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Question Section
                        Text(
                          'Your Questions',
                          style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 8),
                        // Question Input Field
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: TextFormField(
                            controller: _questionController,
                            decoration: InputDecoration(
                              hintText: 'Insert your question here',
                              hintStyle: GoogleFonts.sora(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              filled: false,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Upload File Section
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFA5D6A7), // Light green color
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload File',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade700,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Picture', style: GoogleFonts.sora()),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.upload),
                                    onPressed: _pickImage,
                                  ),
                                ],
                              ),
                              // Display selected image (if any)
                              if (_image != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Image selected: ${_image!.path.split('/').last}',
                                    style: GoogleFonts.sora(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // Submit Button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Handle form submission
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Processing Data')),
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'SUBMIT',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}