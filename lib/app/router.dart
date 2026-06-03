import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/credit_book/domain/credit_sale.dart';
import '../features/credit_book/presentation/credit_form.dart';
import '../features/credit_book/presentation/credit_list_screen.dart';
import '../features/daily_record/presentation/daily_record_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/payments/domain/pending_expense.dart';
import '../features/payments/presentation/expense_form_screen.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/staff/presentation/staff_list_screen.dart';
import '../features/monthly_summary/presentation/monthly_summary_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/weekly_summary/presentation/weekly_summary_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);

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
        builder: (context, state) => const DashboardScreen(),
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
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/expense/add',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: '/payments/expense/edit',
        builder: (context, state) =>
            ExpenseFormScreen(expense: state.extra as PendingExpense),
      ),
      GoRoute(
        path: '/weekly',
        builder: (context, state) => const WeeklySummaryScreen(),
      ),
      GoRoute(
        path: '/monthly',
        builder: (context, state) => const MonthlySummaryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.listen(authStateChangesProvider, (prev, next) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});
