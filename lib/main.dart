import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'blocs/auth_bloc.dart';
import 'blocs/search_bloc.dart';
import 'blocs/project_bloc.dart';
import 'blocs/post_bloc.dart';
import 'blocs/chat_bloc.dart';
import 'blocs/message_bloc.dart';
import 'blocs/subscription_bloc.dart';


import 'route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final boxNames = [
    'usersBox',
    'projectsBox',
    'postsBox',
    'chatsBox',
    'messagesBox',
  ];

  for (var boxName in boxNames) {
    if (await Hive.boxExists(boxName)) {
      await Hive.deleteBoxFromDisk(boxName);
    }
  }

  for (var boxName in boxNames) {
    await Hive.openBox(boxName);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
        BlocProvider<ProjectBloc>(create: (_) => ProjectBloc()),
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<ChatBloc>(create: (_) => ChatBloc()),
        BlocProvider<MessageBloc>(create: (_) => MessageBloc()),
        BlocProvider<SubscriptionBloc>(create: (_) => SubscriptionBloc()),
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
