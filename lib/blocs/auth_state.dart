// lib/blocs/auth_state.dart

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String email;
  final String nickname;
  final String description;

  AuthAuthenticated(this.email, this.nickname, this.description);
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthLoggedOut extends AuthState {}
