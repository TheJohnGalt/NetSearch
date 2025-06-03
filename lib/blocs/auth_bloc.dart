// lib/blocs/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:collection/collection.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Box usersBox = Hive.box('usersBox');

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  final allUsers = usersBox.values.cast<Map>().toList();
  final user = allUsers.firstWhereOrNull(
    (u) => u['email'] == event.email && u['password'] == event.password,
  );
  if (user == null) {
    emit(AuthError('Неверный email или пароль'));
  } else {
    emit(AuthAuthenticated(user['email'], user['nickname'], user['description']));
  }
}

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final allUsers = usersBox.values.cast<Map>().toList();
      final exists = allUsers.any((u) => u['email'] == event.email);
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
      emit(AuthAuthenticated(event.email, event.nickname, event.description));
    } catch (e) {
      emit(AuthError('Ошибка при регистрации'));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthLoggedOut());
  }
}
