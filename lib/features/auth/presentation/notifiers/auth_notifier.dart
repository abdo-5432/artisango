import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/di/service_locator.dart';
import '../data/datasources/auth_remote_data_source.dart';

final authRepositoryProvider = Provider<AuthRemoteDataSource>((ref) {
  final auth = getIt<FirebaseAuth>();
  return AuthRemoteDataSource(auth);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthRemoteDataSource _repo;
  AuthNotifier(this._repo) : super(null) {
    _repo._auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final user = await _repo.signInWithEmail(email, password);
      state = user;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inattendue';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final user = await _repo.signUpWithEmail(email, password);
      state = user;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Erreur inattendue';
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = null;
  }
}
