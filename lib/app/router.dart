import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/credit_book/domain/credit_sale.dart';
import '../features/credit_book/presentation/credit_form.dart';
import '../features/credit_book/presentation/credit_list_screen.dart';
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
      GoRoute(
        path: '/credit',
        builder: (context, state) => const CreditListScreen(),
      ),
      GoRoute(
        path: '/credit/add',
        builder: (context, state) => const CreditForm(),
      ),
      GoRoute(
        path: '/credit/edit',
        builder: (context, state) =>
            CreditForm(sale: state.extra as CreditSale),
      ),
    ],
  );

  ref.listen(authStateChangesProvider, (prev, next) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
