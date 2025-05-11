import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/search_bloc.dart';
import 'blocs/project_bloc.dart';  // новый импорт
import 'pages/auth/login_page.dart';
import 'pages/home/project_create_page.dart'; // новый импорт
import 'pages/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('usersBox');
  await Hive.openBox('projectsBox'); // открываем бокс для проектов

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
        BlocProvider<ProjectBloc>(create: (_) => ProjectBloc()),  // регистрируем ProjectBloc
      ],
      child: MaterialApp(
        title: 'Social Network Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/main': (context) => MainScreen(),
          '/project_create': (context) => ProjectCreatePage(),  // маршрут создания проекта
        },
      ),
    );
  }
}
