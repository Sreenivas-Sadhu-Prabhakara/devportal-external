import 'package:equatable/equatable.dart';

/// Portal sign-in state. In production this is hydrated from a ForgeRock OIDC
/// session (Authorization Code + PKCE); here a hardcoded credential stands in.
class AuthState extends Equatable {
  const AuthState({
    required this.signedIn,
    required this.username,
    required this.email,
    required this.displayName,
    this.signingIn = false,
    this.error = '',
  });

  const AuthState.signedOut()
      : signedIn = false,
        username = '',
        email = '',
        displayName = '',
        signingIn = false,
        error = '';

  final bool signedIn;
  final bool signingIn;
  final String error;
  final String username;
  final String email;
  final String displayName;

  AuthState copyWith({
    bool? signedIn,
    bool? signingIn,
    String? error,
    String? username,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      signedIn: signedIn ?? this.signedIn,
      signingIn: signingIn ?? this.signingIn,
      error: error ?? this.error,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  List<Object?> get props =>
      [signedIn, signingIn, error, username, email, displayName];
}
