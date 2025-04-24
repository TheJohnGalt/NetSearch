import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Box usersBox = Hive.box('usersBox');

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1));

    final users = usersBox.toMap();
    Map? foundUser;
    for (var entry in users.entries) {
      final user = entry.value as Map;
      if (user['email'] == event.email && user['password'] == event.password) {
        foundUser = user;
        break;
      }
    }

    if (foundUser != null) {
      print('User logged in: ${event.email}');
      emit(AuthAuthenticated(
        foundUser['email'],
        foundUser['nickname'] ?? '',
        foundUser['description'] ?? '',
      ));
    } else {
      emit(AuthError('Неверный email или пароль'));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1));

    final users = usersBox.toMap();
    bool exists = false;
    for (var entry in users.entries) {
      final user = entry.value as Map;
      if (user['email'] == event.email) {
        exists = true;
        break;
      }
    }

    if (exists) {
      emit(AuthError('Пользователь с таким email уже существует'));
      return;
    }

    await usersBox.add({
      'email': event.email,
      'password': event.password,
      'nickname': event.nickname,
      'description': event.description,
    });

    print('User registered: ${event.email}');

    emit(AuthAuthenticated(event.email, event.nickname, event.description));
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    print('Logout requested');
    emit(AuthLoggedOut());
  }
}
