// frontend/lib/main.dart
import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/auth_check_screen.dart';
import 'config/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..initializeAuth(),
      child: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  GoRouter? _router;

  @override
  void dispose() {
    AppRouter.dispose(); // Cleanup router
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Jika masih loading, tampilkan AuthCheckScreen
        if (authProvider.isAuthenticating) {
          return const MaterialApp(
            home: AuthCheckScreen(),
            debugShowCheckedModeBanner: false,
          );
        }

        // Buat router hanya sekali atau saat auth state berubah
        _router ??= AppRouter.createRouter(authProvider);

        // Auth sudah selesai, tampilkan app normal
        return MaterialApp.router(
          title: 'PanenIn',
          debugShowCheckedModeBanner: false,
          routerConfig: _router!,
        );
      },
    );
  }
}