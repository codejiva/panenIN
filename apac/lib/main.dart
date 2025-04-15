import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'config/themes/AppTheme.dart';

void main() {
  runApp(const Agribuddy());
}

class Agribuddy extends StatelessWidget {
  const Agribuddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agriculture IoT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.onboarding,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}