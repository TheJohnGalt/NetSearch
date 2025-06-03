// lib/route_generator.dart

import 'package:flutter/material.dart';

import 'pages/auth/login_page.dart';
import 'pages/home/profile_page.dart';
import 'pages/home/project_create_page.dart';
import 'pages/home/project_page.dart';
import 'pages/home/search_page.dart';
import 'pages/home/chats_page.dart';
import 'pages/home/chat_page.dart'; // Новый импорт
import 'pages/main_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());

      case '/main':
        return MaterialPageRoute(builder: (_) => MainScreen());

      case '/profile':
        if (args is Map<String, dynamic>?) {
          return MaterialPageRoute(
            builder: (_) => ProfilePage(userData: args),
          );
        }
        return MaterialPageRoute(builder: (_) => ProfilePage());

      case '/search':
        return MaterialPageRoute(builder: (_) => SearchPage());

      case '/project_create':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProjectCreatePage(),
            settings: RouteSettings(arguments: args),
          );
        }
        return _errorRoute();

      case '/project':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ProjectPage(),
            settings: RouteSettings(arguments: args),
          );
        }
        return _errorRoute();

      case '/chats':
        return MaterialPageRoute(builder: (_) => ChatsPage());

      case '/chat': // Новый маршрут для страницы переписки
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChatPage(),
            settings: RouteSettings(arguments: args),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Ошибка')),
        body: Center(child: Text('Страница не найдена')),
      ),
    );
  }
}
