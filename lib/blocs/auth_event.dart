abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String nickname;
  final String description;

  RegisterRequested(this.email, this.password, this.nickname, this.description);
}

class LogoutRequested extends AuthEvent {}
