import 'package:flutter/material.dart';
import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';


class WelcomeChatScreen extends StatefulWidget {
  const WelcomeChatScreen({super.key});

  @override
  _WelcomeChatScreenState createState() => _WelcomeChatScreenState();
}

class _WelcomeChatScreenState extends State<WelcomeChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SharedAppBar(
        onNotificationPressed: () {
          print('Notifikasi ditekan dari HomeScreen!');
        },
        onProfilePressed: () {
          print('Profile ditekan dari HomeScreen!');
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildWelcomeHeader(),
              const SizedBox(height: 40),
              Image.asset('assets/images/Illustration.png'),
              const SizedBox(height: 32),
              _buildDescriptionText(),
              const SizedBox(height: 40),
              _buildNewChatButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return const Text(
      'Welcome',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD1E7DD),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern (optional - dapat ditambahkan grid pattern)
          _buildBackgroundPattern(),
          // Main illustration elements
          _buildIllustrationElements(),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPatternPainter(),
      ),
    );
  }

  Widget _buildIllustrationElements() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Left side - Chat bubbles and people
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChatBubbleWithPeople(),
            ],
          ),
          // Right side - Plant and agriculture elements
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAgricultureElements(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubbleWithPeople() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.people,
        size: 40,
        color: Color(0xFF48BB78),
      ),
    );
  }

  Widget _buildAgricultureElements() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF48BB78),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 12,
            left: 12,
            child: Icon(
              Icons.eco,
              size: 24,
              color: Colors.white,
            ),
          ),
          const Positioned(
            bottom: 12,
            right: 12,
            child: Icon(
              Icons.agriculture,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Column(
      children: [
        const Text(
          'Chat with our virtual assistant or connect with fellow farmers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF48BB78),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Conversations keep farmers connected — ask questions, share tips, and get real-time advice from the community. Any chats you\'re part of will appear here.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNewChatButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Handle new chat action
          _startNewChat();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF48BB78),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'New Chat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewChat() {
    // Navigator.push atau logic lainnya
    context.goNamed('chatroom_list');
  }
}

// Custom painter untuk membuat grid pattern di background
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1E7DD).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double gridSize = 20;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}