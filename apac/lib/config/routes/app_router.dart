import 'package:PanenIn/features/home/screens/maps_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../shared/widgets/buttom_navbar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Routes tanpa bottom navigation bar
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Shell route untuk halaman dengan bottom navigation bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          // Tambahkan route lain sesuai menu di bottom navbar
          // Jika halaman belum dibuat, buat halaman kosong (placeholder) dulu
          GoRoute(
            path: '/maps',
            name: 'maps',
            builder: (context, state) => const MapsScreen(),
          ),
          GoRoute(
            path: '/monitoring',
            name: 'monitoring',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Monitoring Screen'))),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Profile Screen'))),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Chat Screen'))),
          ),
        ],
      ),
    ],
    //errorBuilder: (context, state) => const NotFoundScreen(),
  );

  // Helper untuk memeriksa status login user
  static bool checkIfUserIsLoggedIn() {
    // Implementasi logika untuk memeriksa status login
    return false; // Ganti dengan logika sebenarnya
  }
}

// Widget Scaffold dengan Bottom Navigation Bar
class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/home',
    '/maps',
    '/monitoring',
    '/profile',
    '/chat',
  ];

  @override
  Widget build(BuildContext context) {
    // Tentukan index berdasarkan path saat ini
    final String location = GoRouterState.of(context).uri.path;
    _currentIndex = _routes.contains(location) ? _routes.indexOf(location) : 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Navigasi ketika item bottom bar ditekan
          context.go(_routes[index]);
        },
      ),
    );
  }
}