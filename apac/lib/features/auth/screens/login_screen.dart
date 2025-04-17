import 'package:flutter/material.dart';
import '../../../config/constants/colors.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome AgriHero!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SocialButton(
                text: 'CONTINUE WITH GOOGLE',
                icon: Image.network(
                  '/api/placeholder/24/24',
                  width: 24,
                  height: 24,
                ),
                onPressed: () => AuthProvider.signInWithGoogle(),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'OR LOG IN WITH EMAIL',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                hintText: 'Email address',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'LOG IN',
                onPressed: () => AuthProvider.login(),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.goNamed('signup'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'ALREADY HAVE AN ACCOUNT? ',
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'SIGN UP',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}