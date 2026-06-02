import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/firebase_providers.dart';
import '../data/auth_repository.dart';
import '../data/firebase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final loginControllerProvider =
    AsyncNotifierProvider<LoginController, void>(LoginController.new);

class LoginController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }
}

final logoutControllerProvider =
    AsyncNotifierProvider<LogoutController, void>(LogoutController.new);

class LogoutController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}
