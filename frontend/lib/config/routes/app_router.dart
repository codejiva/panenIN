// lib/config/routes/app_router.dart - CORRECTED VERSION
import 'package:PanenIn/features/auth/screens/profile_screen.dart';
import 'package:PanenIn/features/auth/screens/sign_in_screen.dart';
import 'package:PanenIn/features/auth/screens/sign_up_screen.dart';
import 'package:PanenIn/features/auth/services/auth_service.dart';
import 'package:PanenIn/features/chatbot/screens/chatroom_list_screen.dart';
import 'package:PanenIn/features/chatbot/screens/chatroom_screen.dart';
import 'package:PanenIn/features/chatbot/screens/welcome_screen.dart';
import 'package:PanenIn/features/chatbot/services/chatbot_service.dart';
import 'package:PanenIn/features/forum/screens/question_detail_screen.dart';
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
  static GoRouter? _router;

  static GoRouter createRouter(AuthProvider authProvider) {
    _router?.dispose();

    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

    _router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,

      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final location = state.uri.path;

        final publicRoutes = ['/', '/login', '/signup'];
        final isPublicRoute = publicRoutes.contains(location);

        if (isLoggedIn && isPublicRoute) {
          return '/home';
        }

        if (!isLoggedIn && !isPublicRoute) {
          return '/login';
        }

        return null;
      },

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

        // MOVED: Chat route to root level for back button
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) {
            final conversationId = state.uri.queryParameters['conversationId'];
            return PanenAIChatScreen(
              conversationId: conversationId,
            );
          },
        ),

        // MOVED: Profile route to root level for back button
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        // MOVED: Post detail to root level for back button
        GoRoute(
          path: '/post/:postId',
          name: 'post_detail',
          builder: (context, state) {
            final postIdString = state.pathParameters['postId'];

            if (postIdString == null || postIdString.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/forum');
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

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

        // MOVED: Land detail to root level for back button
        GoRoute(
          path: '/land/:landId',
          name: 'landdetail',
          builder: (context, state) {
            final landId = state.pathParameters['landId'];
            if (landId == null || landId.isEmpty) {
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

        // MOVED: Question form to root level for back button
        GoRoute(
          path: '/ask',
          name: 'ask_question',
          builder: (context, state) => const QuestionFormScreen(),
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

            // Chatbot routes - SIMPLIFIED without nested routes
            GoRoute(
              path: '/chatbot',
              name: 'chatbot',
              redirect: (context, state) async {
                try {
                  final conversations = await ChatService.getUserConversations(context);
                  if (conversations.isNotEmpty) {
                    return '/chatbot/list';
                  }
                } catch (e) {
                  print('Error checking conversations: $e');
                }
                return null;
              },
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WelcomeChatScreen(),
              ),
            ),

            GoRoute(
              path: '/chatbot/list',
              name: 'chatroom_list',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatroomListScreen(),
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
              path: '/monitoring',
              name: 'monitoring',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ListLandDashboard(),
              ),
            ),

            GoRoute(
              path: '/forum',
              name: 'forum',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ForumScreen(),
              ),
            ),
          ],
        ),
      ],
    );

    return _router!;
  }

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

    // Find the best matching route
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