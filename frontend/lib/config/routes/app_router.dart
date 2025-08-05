import 'package:PanenIn/features/chatbot/screens/chatroom_screen.dart';
import 'package:PanenIn/features/chatbot/screens/welcome_screen.dart';
import 'package:PanenIn/features/forum/screens/answer_screen.dart';
import 'package:PanenIn/features/forum/screens/forum_screen.dart';
import 'package:PanenIn/features/forum/screens/question_form_screen.dart';
import 'package:PanenIn/features/maps/screens/maps_screen.dart';
import 'package:PanenIn/features/monitoring/screens/landdetail_screen.dart';
import 'package:PanenIn/features/monitoring/screens/listland_screen.dart' hide FieldStatus, FieldData;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../shared/widgets/buttom_navbar.dart';
import 'package:PanenIn/features/auth/providers/auth_provider.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Create router dengan AuthProvider untuk redirect logic
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,

      // Redirect logic berdasarkan authentication status
      redirect: (context, state) {
        final isAuthenticating = authProvider.isAuthenticating;
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.uri.path;

        // Jika sedang melakukan pengecekan auth, tampilkan splash/loading
        if (isAuthenticating && location != '/') {
          return '/';
        }

        // Routes yang tidak memerlukan login
        final publicRoutes = ['/', '/login', '/signup'];
        final isPublicRoute = publicRoutes.contains(location);

        // Jika sudah login dan mengakses public routes, redirect ke home
        if (isLoggedIn && isPublicRoute && !isAuthenticating) {
          return '/home';
        }

        // Jika belum login dan mengakses protected routes, redirect ke login
        if (!isLoggedIn && !isPublicRoute && !isAuthenticating) {
          return '/login';
        }

        // No redirect needed
        return null;
      },

      routes: [
        // Onboarding/Splash Screen - juga berfungsi sebagai loading screen
        GoRoute(
          path: '/',
          name: 'onboarding',
          builder: (context, state) {
            // Jika sedang melakukan auth check, tampilkan loading
            if (authProvider.isAuthenticating) {
              return const AuthCheckScreen();
            }
            return const OnboardingScreen();
          },
        ),

        // Auth routes (public)
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            // Tidak perlu create AuthProvider baru karena sudah ada di main
            return const SignInScreen();
          },
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            // Tidak perlu create AuthProvider baru karena sudah ada di main
            return const SignUpScreen();
          },
        ),

        // Chatroom khusus (tanpa navbar, tapi perlu auth)
        GoRoute(
          path: '/chatroom',
          name: 'chatroom',
          builder: (context, state) => const PanenAIChatScreen(),
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
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/maps',
              name: 'maps',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MapScreen(),
              ),
            ),
            GoRoute(
              path: '/chatbot',
              name: 'chatbot',
              pageBuilder: (context, state) => const NoTransitionPage(
                  child: WelcomeChatScreen()
              ),
            ),
            GoRoute(
              path: '/monitoring',
              name: 'monitoring',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ListLandDashboard(),
              ),
              routes: [
                GoRoute(
                  path: 'detail/:landId',
                  name: 'detail',
                  builder: (context, state) {
                    final landId = state.pathParameters['landId'] ?? '';
                    final landName = state.uri.queryParameters['landName'] ?? 'Unknown Land';
                    final statusStr = state.uri.queryParameters['status'] ?? 'healthy';

                    final status = switch (statusStr.toLowerCase()) {
                      'unhealthy' => FieldStatus.unhealthy,
                      'critical' => FieldStatus.critical,
                      _ => FieldStatus.healthy,
                    };

                    return LandDetailScreen(
                      landId: landId,
                      landName: landName,
                      currentStatus: status,
                      fieldData: state.extra is FieldData ? state.extra as FieldData : null,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/forum',
              name: 'forum',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ForumScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'answer',
                  name: 'answer',
                  builder: (context, state) => const AnswerScreen(),
                ),
                GoRoute(
                  path: 'questionform',
                  name: 'ask',
                  builder: (context, state) => const QuestionFormScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Getter untuk backward compatibility (jika diperlukan)
  static GoRouter get router => throw UnsupportedError(
      'Use AppRouter.createRouter(authProvider) instead'
  );
}

// Screen untuk menampilkan loading saat pengecekan auth
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              'Panen In',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            const Text(
              'Solusi Pertanian Modern',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Memuat...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  static const List<String> _routes = [
    '/home',
    '/maps',
    '/chatbot',
    '/monitoring',
    '/forum',
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    // Find the best matching route
    _currentIndex = _routes.indexWhere((route) => location.startsWith(route));
    if (_currentIndex == -1) _currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            context.go(_routes[index]);
          }
        },
      ),
    );
  }
}