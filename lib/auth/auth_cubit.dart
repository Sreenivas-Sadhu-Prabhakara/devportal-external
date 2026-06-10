import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

/// Hardcoded demo credentials. In production this is replaced by a ForgeRock
/// OIDC client (Authorization Code + PKCE).
const String kPortalUsername = 'admin';
const String kPortalPassword = 'passWORD1234#';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.signedOut());

  // The signed-in demo developer (apps fixtures are seeded for this email).
  static const _demoEmail = 'dev@example.com';
  static const _demoName = 'Sam Rivera';

  Future<void> signIn(String username, String password) async {
    emit(state.copyWith(signingIn: true, error: ''));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (username.trim() == kPortalUsername && password == kPortalPassword) {
      emit(AuthState(
        signedIn: true,
        username: username.trim(),
        email: _demoEmail,
        displayName: _demoName,
      ));
    } else {
      emit(const AuthState.signedOut()
          .copyWith(error: 'Invalid username or password.'));
    }
  }

  void signOut() => emit(const AuthState.signedOut());
}
