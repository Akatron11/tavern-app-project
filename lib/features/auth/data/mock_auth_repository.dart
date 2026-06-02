import 'dart:async';

import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({String? initialUid}) : _uid = initialUid;

  final _controller = StreamController<String?>();
  String? _uid;
  bool shouldThrowOnSignIn = false;

  @override
  Stream<String?> authStateChanges() async* {
    yield _uid;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (shouldThrowOnSignIn) {
      throw Exception('Geçersiz kimlik bilgileri');
    }
    _uid = 'mock-uid';
    _controller.add(_uid);
  }

  @override
  Future<void> signOut() async {
    _uid = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
