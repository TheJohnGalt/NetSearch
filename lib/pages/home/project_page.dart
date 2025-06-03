import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/post_bloc.dart';
import '../../blocs/post_event.dart';
import '../../blocs/post_state.dart';
import '../../blocs/subscription_bloc.dart';
import '../../blocs/subscription_event.dart';
import '../../blocs/subscription_state.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late Map<String, dynamic> project;
  late String currentUserEmail;
  late String currentUserNickname;
  bool? isSubscribed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    project = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserEmail = authState.email;
      currentUserNickname = authState.nickname;
      context.read<SubscriptionBloc>().add(LoadSubscriptions(currentUserEmail));
    } else {
      currentUserEmail = '';
      currentUserNickname = '';
    }

    context.read<PostBloc>().add(LoadPosts(project['title']));
  }

  void _showAddPostDialog() {
    final postController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Создать пост'),
        content: TextField(
          controller: postController,
          maxLines: 5,
          decoration: InputDecoration(hintText: 'Введите текст поста'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final content = postController.text.trim();
              if (content.isNotEmpty) {
                context.read<PostBloc>().add(AddPost(project['title'], content));
                Navigator.pop(context);
              }
            },
            child: Text('Опубликовать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = currentUserEmail == project['ownerEmail'];
    final String ownerNickname = project['ownerNickname'] ?? 'не известен';

    return Scaffold(
      appBar: AppBar(
        title: Text(project['title'] ?? 'Сообщество'),
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: _showAddPostDialog,
              tooltip: 'Добавить пост',
              child: Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project['title'] ?? '',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Создатель: $ownerNickname',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              project['description'] ?? '',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            if (!isOwner)
              BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  bool subscribed = false;
                  if (state is SubscriptionLoaded) {
                    subscribed = state.subscriptions.contains(project['title']);
                  } else if (state is SubscriptionChanged) {
                    subscribed = state.isSubscribed;
                  }
                  return ElevatedButton(
                    onPressed: subscribed
                        ? null
                        : () {
                            context.read<SubscriptionBloc>().add(
                                  SubscribeToProject(currentUserEmail, project['title']),
                                );
                          },
                    child: Text(subscribed ? 'Вы подписаны' : 'Подписаться'),
                  );
                },
              ),
            SizedBox(height: 24),
            Text(
              'Посты сообщества:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is PostLoaded) {
                    if (state.posts.isEmpty) {
                      return Center(child: Text('Постов пока нет'));
                    }
                    return ListView.separated(
                      itemCount: state.posts.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['projectTitle'] ?? 'Неизвестное сообщество',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(post['content'] ?? ''),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up_alt_outlined),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.thumb_down_alt_outlined),
                                onPressed: () {},
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text('Комментарии'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is PostError) {
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
