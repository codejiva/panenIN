import 'package:flutter/material.dart';
import '../../../config/constants/colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _privacyPolicyChecked = false;

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
                'Create your account',
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
                hintText: 'Name',
                suffixIcon: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Email address',
                suffixIcon: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Password',
                obscureText: true,
                suffixIcon: const Icon(
                  Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _privacyPolicyChecked,
                    onChanged: (value) {
                      setState(() {
                        _privacyPolicyChecked = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  const Text('I have read the '),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'GET STARTED',
                onPressed: () => AuthProvider.signUp(),
                isDisabled: !_privacyPolicyChecked,
              ),
            ],
          ),
        ),
      ),
    );
  }
}