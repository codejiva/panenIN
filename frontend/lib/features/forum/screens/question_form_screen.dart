import 'package:PanenIn/config/constants/colors.dart';
import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:PanenIn/features/forum/services/forum_service.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class QuestionFormScreen extends StatefulWidget {
  const QuestionFormScreen({super.key});

  @override
  State<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends State<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _topicController = TextEditingController(text: 'Agriculture');
  final ForumService _forumService = ForumService();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check if user is authenticated
  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isLoggedIn) {
        _showErrorSnackBar('You must be logged in to ask a question');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.goNamed('login');
          }
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get user data from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is logged in
    if (!authProvider.isLoggedIn || authProvider.userData == null) {
      _showErrorSnackBar('You must be logged in to submit a question');
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showErrorSnackBar('Please enter a title for your question');
      return;
    }

    if (content.isEmpty) {
      _showErrorSnackBar('Please enter your question details');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user ID from auth provider with multiple fallbacks
      final userData = authProvider.userData!;

      // Try different possible field names for user ID
      final userId = userData['id'] ??
          userData['user_id'] ??
          userData['userId'] ??
          userData['ID'];

      final username = userData['username'] ??
          userData['name'] ??
          userData['email'] ??
          'Unknown User';

      // Validate user ID
      if (userId == null) {
        debugPrint('Available user data fields: ${userData.keys.toList()}');
        _showErrorSnackBar('User ID not found. Please login again.');
        return;
      }

      // Debug: Print user info
      debugPrint('Submitting as User ID: $userId');
      debugPrint('Username: $username');
      debugPrint('User Data: ${authProvider.userData}');

      // Submit the question
      await _forumService.submitForumPost(
        userId: userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
        title: title,
        content: content,
      );

      // Show success message
      if (mounted) {
        _showSuccessSnackBar('Question submitted successfully!');

        // Clear the form
        _titleController.clear();
        _contentController.clear();
        setState(() {
          _image = null;
        });

        // Navigate back to forum and trigger refresh
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            // Pop back to forum with refresh signal
            context.goNamed('forum', extra: {'refresh': true});
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Simple error handling
        String errorMessage = 'Failed to submit question. Please try again.';

        if (e.toString().contains('Network error')) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        }

        _showErrorSnackBar(errorMessage);
      }
      debugPrint('Error submitting question: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {
          debugPrint('Notification pressed from QuestionFormScreen');
        },
        onProfilePressed: () {
          debugPrint('Profile pressed from QuestionFormScreen');
        },
      ),
      body: Container(
        color: AppColors.secondary,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final username = authProvider.userData?['username'] ??
            authProvider.userData?['name'] ??
            'Unknown User';

        return Padding(
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
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    elevation: 4,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask your question',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Posting as: $username',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(0, -3),
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildTopicSection(),
            const SizedBox(height: 20),
            _buildTitleSection(),
            const SizedBox(height: 20),
            _buildQuestionSection(),
            const SizedBox(height: 20),
            _buildUploadSection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topic',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question Title',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter a brief title for your question',
              hintStyle: GoogleFonts.sora(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              fillColor: Colors.transparent,
              filled: false,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              if (value.trim().length < 10) {
                return 'Title must be at least 10 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Question Details',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: TextFormField(
            controller: _contentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe your question in detail...',
              hintStyle: GoogleFonts.sora(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              fillColor: Colors.transparent,
              filled: false,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your question details';
              }
              if (value.trim().length < 20) {
                return 'Please provide more details (at least 20 characters)';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFA5D6A7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Image (Optional)',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_image == null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.photo_camera,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('Add Picture', style: GoogleFonts.sora()),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image: ${_image!.path.split('/').last}',
                    style: GoogleFonts.sora(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _removeImage,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isSubmitting ? null : _submitQuestion,
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SUBMIT QUESTION',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}