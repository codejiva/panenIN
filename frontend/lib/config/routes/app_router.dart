// frontend/lib/config/routes/app_router.dart
import 'package:PanenIn/features/auth/screens/profile_screen.dart';
import 'package:PanenIn/features/auth/screens/sign_in_screen.dart';
import 'package:PanenIn/features/auth/screens/sign_up_screen.dart';
import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:PanenIn/features/chatbot/screens/chatroom_screen.dart';
import 'package:PanenIn/features/chatbot/screens/welcome_screen.dart';
import 'package:PanenIn/features/forum/screens/question_detail_screen.dart'; // Changed from answer_screen
import 'package:PanenIn/features/forum/screens/forum_screen.dart';
import 'package:PanenIn/features/forum/screens/question_form_screen.dart';
import 'package:PanenIn/features/home/screens/home_screen.dart';
import 'package:PanenIn/features/maps/screens/maps_screen.dart';
import 'package:PanenIn/features/monitoring/screens/landdetail_screen.dart';
import 'package:PanenIn/features/monitoring/screens/listland_screen.dart' hide FieldStatus, FieldData;
import 'package:PanenIn/features/onboarding/screens/onboarding_screen.dart';
import 'package:PanenIn/shared/widgets/buttom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Buat GlobalKey yang unik untuk setiap instance
  static GoRouter? _router;

  static GoRouter createRouter(AuthProvider authProvider) {
    // Dispose router lama jika ada
    _router?.dispose();

    // Buat GlobalKey baru setiap kali
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

    _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: false, // Nonaktifkan untuk mengurangi log

      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.uri.path;

        final publicRoutes = ['/', '/login', '/signup'];
        final isPublicRoute = publicRoutes.contains(location);

        // Redirect logged in users away from public routes
        if (isLoggedIn && isPublicRoute) {
          return '/home';
        }

        // Redirect non-logged in users to login (except public routes)
        if (!isLoggedIn && !isPublicRoute) {
          return '/login';
        }

        return null;
      },

      // Add error handling
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),

      routes: [
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

        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        GoRoute(
          path: '/post/:postId', // Changed from 'answer' to 'post' for clarity
          name: 'post_detail', // Changed name to be more descriptive
          builder: (context, state) {
            final postIdString = state.pathParameters['postId'];

            // Validate postId
            if (postIdString == null || postIdString.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/forum');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Additional validation for numeric postId
            final postId = int.tryParse(postIdString);
            if (postId == null || postId <= 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/forum');
              });
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Invalid post ID'),
                      SizedBox(height: 16),
                      Text('Redirecting to forum...'),
                    ],
                  ),
                ),
              );
            }

            return ForumDetailScreen(postId: postIdString);
          },
        ),

        ShellRoute(
          navigatorKey: shellNavigatorKey,
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
              path: '/chatbot',
              name: 'chatbot',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WelcomeChatScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'chat',
                  name: 'chatroom',
                  builder: (context, state) {
                    return const PanenAIChatScreen();
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/maps',
              name: 'maps',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MapScreen(),
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
                  name: 'landdetail',
                  builder: (context, state) {
                    final landId = state.pathParameters['landId'];
                    if (landId == null || landId.isEmpty) {
                      // Redirect to monitoring if landId is invalid
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.go('/monitoring');
                      });
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final landName = state.uri.queryParameters['name'] ?? 'Unknown Land';
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
                  path: 'ask', // Simplified path
                  name: 'ask_question', // More descriptive name
                  builder: (context, state) => const QuestionFormScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return _router!;
  }

  // Method untuk cleanup
  static void dispose() {
    _router?.dispose();
    _router = null;
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

    // Find the best matching route with better logic
    int newIndex = 0;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) {
        newIndex = i;
        break;
      }
    }

    // Only update if different to avoid unnecessary rebuilds
    if (_currentIndex != newIndex) {
      _currentIndex = newIndex;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index && index < _routes.length) {
            context.go(_routes[index]);
          }
        },
      ),
    );
  }
}