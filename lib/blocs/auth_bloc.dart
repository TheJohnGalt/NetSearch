import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1)); // имитация загрузки
    // Плейсхолдер: здесь должна быть логика входа
    print('Login requested: email=${event.email}, password=${event.password}');
    // Для примера считаем, что вход успешен
    emit(AuthAuthenticated(event.email));
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 1)); // имитация загрузки
    // Плейсхолдер: здесь должна быть логика регистрации
    print('Register requested: email=${event.email}, password=${event.password}');
    // Для примера считаем, что регистрация успешна и сразу авторизуем пользователя
    emit(AuthAuthenticated(event.email));
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    print('Logout requested');
    emit(AuthLoggedOut());
  }
}
