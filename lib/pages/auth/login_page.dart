import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is AuthLoggedOut) {
            _emailController.clear();
            _passwordController.clear();
            _nicknameController.clear();
            _descriptionController.clear();
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLogin ? _buildLoginForm(context) : _buildRegisterForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 28),
        Text(
          'Имя профиля или электронная почта',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: _inputDecoration('E-mail'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        Text(
          'Введите ваш пароль',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration('пароль').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {

            },
            child: Text(
              'Забыли пароль?',
              style: TextStyle(
                color: Color(0xFF4A6CF7),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(height: 32),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                _gradientButton(
                  text: 'Войти',
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    context.read<AuthBloc>().add(LoginRequested(email, password));
                  },
                ),
                SizedBox(height: 16),
                _outlinedButton(
                  text: 'Зарегистрироваться',
                  onPressed: () {
                    setState(() {
                      _isLogin = false;
                    });
                  },
                ),
              ],
            );
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 28),
        Text(
          'Регистрация',
          style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 24),
        Text(
          'Имя пользователя',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _nicknameController,
          decoration: _inputDecoration('Введите имя пользователя'),
        ),
        SizedBox(height: 16),
        Text(
          'Электронная почта',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: _inputDecoration('Введите email'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        Text(
          'Пароль',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _inputDecoration('Введите пароль').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Описание профиля',
          style: TextStyle(fontSize: 15, color: Colors.black87),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          decoration: _inputDecoration('Расскажите о себе'),
          maxLines: 3,
        ),
        SizedBox(height: 28),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                _gradientButton(
                  text: 'Зарегистрироваться',
                  onPressed: () {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final nickname = _nicknameController.text.trim();
                    final description = _descriptionController.text.trim();
                    context.read<AuthBloc>().add(RegisterRequested(email, password, nickname, description));
                  },
                ),
                SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = true;
                      });
                    },
                    child: Text(
                      'Уже есть аккаунт? Войти',
                      style: TextStyle(
                        color: Color(0xFF4A6CF7),
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Color(0xFFF6F6F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _gradientButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A6CF7), Color(0xFF6BA5FF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xFF4A6CF7),
          side: BorderSide(color: Color(0xFF4A6CF7), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF4A6CF7),
          ),
        ),
      ),
    );
  }
}
