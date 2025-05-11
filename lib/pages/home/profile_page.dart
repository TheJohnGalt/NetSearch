import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/project_bloc.dart';
import '../../blocs/project_event.dart';
import '../../blocs/project_state.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProjectBloc>().add(LoadProjects(authState.email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    String email = '';
    String nickname = '';
    String description = '';

    if (authState is AuthAuthenticated) {
      email = authState.email;
      nickname = authState.nickname;
      description = authState.description;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль пользователя'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              // Отправляем событие выхода
              context.read<AuthBloc>().add(LogoutRequested());

              // Переходим на страницу входа, удаляя все предыдущие экраны
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Ник: $nickname', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Описание:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 4),
            Text(description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Добавить сообщество'),
              onPressed: () {
                Navigator.pushNamed(context, '/project_create', arguments: email);
              },
            ),
            SizedBox(height: 24),
            Text('Мои сообщества:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ProjectLoaded) {
                    if (state.projects.isEmpty) {
                      return Center(child: Text('Вы ещё не создали ни одного сообщества'));
                    }
                    return ListView.builder(
                      itemCount: state.projects.length,
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        return Card(
                          child: ListTile(
                            title: Text(project['title'] ?? ''),
                            subtitle: Text(project['description'] ?? ''),
                          ),
                        );
                      },
                    );
                  } else if (state is ProjectError) {
                    return Center(child: Text(state.message));
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
