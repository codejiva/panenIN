import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes/app_router.dart';
import 'config/themes/AppTheme.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  runApp(const Agribuddy());
}

class Agribuddy extends StatelessWidget {
  const Agribuddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initializeAuth(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Agriculture IoT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(authProvider),
          );
        },
      ),
    );
  }
}