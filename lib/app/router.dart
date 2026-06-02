import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/daily_record/presentation/daily_record_screen.dart';
import '../features/staff/presentation/staff_list_screen.dart';
import 'placeholder_home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);

      // Henüz yükleniyorsa yönlendirme yapma
      if (authState.isLoading) return null;

      final isLoggedIn = authState.asData?.value != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaceholderHomeScreen(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffListScreen(),
      ),
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyRecordScreen(),
      ),
    ],
  );

  ref.listen(authStateChangesProvider, (prev, next) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
