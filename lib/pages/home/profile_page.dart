import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_event.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/project_bloc.dart';
import '../../blocs/project_event.dart';
import '../../blocs/project_state.dart';
import '../../blocs/chat_bloc.dart';
import '../../blocs/chat_event.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userData});

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

  void _onWriteMessagePressed() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final chatBloc = context.read<ChatBloc>();
      try {
        final chatId = await chatBloc.createOrGetChatId(authState.email, {
          'email': email,
          'nickname': nickname,
        });
        Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'chatId': chatId,
            'otherUser': {
              'email': email,
              'nickname': nickname,
            },
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при открытии чата')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Никнейм
            Text(
              nickname,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            // Email
            Text(
              email,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            // Кнопка сообщения или добавить сообщество
            if (!isCurrentUser)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A6CF7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _onWriteMessagePressed,
                  child: Text('Сообщение', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                ),
              ),
            if (isCurrentUser)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Добавить сообщество', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A6CF7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/project_create', arguments: email);
                  },
                ),
              ),
            SizedBox(height: 24),
            // О себе
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'О себе',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                description.isNotEmpty
                    ? description
                    : 'Описание отсутствует',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            SizedBox(height: 28),
            // Список проектов
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isCurrentUser ? 'Мои сообщества' : 'Сообщества пользователя',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 12),
            BlocBuilder<ProjectBloc, ProjectState>(
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is ProjectLoaded) {
                  if (state.projects.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          isCurrentUser
                              ? 'Вы ещё не создали ни одного сообщества'
                              : 'У пользователя нет сообществ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: state.projects.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                          title: Text(
                            project['title'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: project['description'] != null && project['description'].toString().isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    project['description'],
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                )
                              : null,
                          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                          onTap: () {
                            Navigator.pushNamed(context, '/project', arguments: project);
                          },
                        ),
                      );
                    },
                  );
                } else if (state is ProjectError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text(state.message)),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
