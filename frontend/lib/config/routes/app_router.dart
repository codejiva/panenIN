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
import 'package:provider/provider.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../shared/widgets/buttom_navbar.dart';
import 'package:PanenIn/features/auth/providers/auth_provider.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Routes without bottom navigation bar
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
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SignUpScreen(),
          );
        },
      ),
      GoRoute(
        path: '/chatroom',
        name: 'chatroom',
        builder: (context, state) => const PanenAIChatScreen(),
      ),

      // Shell route for pages with bottom navigation bar
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