import 'package:go_router/go_router.dart';

import 'placeholder_home_screen.dart';

/// Uygulama yönlendiricisi. Faz 2'de auth guard (oturum yoksa /login) eklenecek.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlaceholderHomeScreen(),
    ),
  ],
);
