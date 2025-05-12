// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/search_bloc.dart';
import 'blocs/project_bloc.dart';
import 'blocs/post_bloc.dart'; // Добавлен импорт
import 'route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('usersBox');
  await Hive.openBox('projectsBox');
  await Hive.openBox('postsBox'); // Открываем бокс для постов

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
        BlocProvider<ProjectBloc>(create: (_) => ProjectBloc()),
        BlocProvider<PostBloc>(create: (_) => PostBloc()), // Регистрируем PostBloc
      ],
      child: MaterialApp(
        title: 'Social Network Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
