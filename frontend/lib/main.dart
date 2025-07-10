import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'config/themes/AppTheme.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const Agribuddy());
}

class Agribuddy extends StatelessWidget {
  const Agribuddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Agriculture IoT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}