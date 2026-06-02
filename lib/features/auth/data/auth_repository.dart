abstract class AuthRepository {
  Stream<String?> authStateChanges();
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}
