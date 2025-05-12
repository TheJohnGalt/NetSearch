// lib/pages/home/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/project_bloc.dart';
import '../../blocs/project_event.dart';
import '../../blocs/project_state.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String email;
  late String nickname;
  late String description;

  bool isCurrentUser = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.userData != null) {
      email = widget.userData!['email'] ?? '';
      nickname = widget.userData!['nickname'] ?? '';
      description = widget.userData!['description'] ?? '';
      isCurrentUser = false;
      // Загружаем проекты пользователя, чей профиль просматриваем
      context.read<ProjectBloc>().add(LoadProjects(email));
    } else {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        email = authState.email;
        nickname = authState.nickname;
        description = authState.description;
        isCurrentUser = true;
        context.read<ProjectBloc>().add(LoadProjects(email));
      } else {
        email = '';
        nickname = '';
        description = '';
        isCurrentUser = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Мой профиль' : 'Профиль пользователя'),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: Icon(Icons.logout),
                  tooltip: 'Выйти',
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                ),
              ]
            : null,
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
            if (isCurrentUser) ...[
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Добавить сообщество'),
                onPressed: () {
                  Navigator.pushNamed(context, '/project_create', arguments: email);
                },
              ),
              SizedBox(height: 24),
              Text('Мои сообщества:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ] else ...[
              Text('Сообщества пользователя:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
            SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ProjectBloc, ProjectState>(
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ProjectLoaded) {
                    if (state.projects.isEmpty) {
                      return Center(child: Text(isCurrentUser ? 'Вы ещё не создали ни одного сообщества' : 'У пользователя нет сообществ'));
                    }
                    return ListView.builder(
                      itemCount: state.projects.length,
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        return Card(
                          child: ListTile(
                            title: Text(project['title'] ?? ''),
                            subtitle: Text(project['description'] ?? ''),
                            onTap: () {
                              Navigator.pushNamed(context, '/project', arguments: project);
                            },
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
