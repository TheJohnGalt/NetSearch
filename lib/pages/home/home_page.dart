import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../blocs/post_bloc.dart';
import '../../blocs/post_event.dart';
import '../../blocs/post_state.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> subscriptions = [];
  String currentUserEmail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserEmail = authState.email;
      final usersBox = Hive.box('usersBox');
      final users = usersBox.values.cast<Map>().toList();
      Map? user;
      for (final u in users) {
        if (u['email'] == currentUserEmail) {
          user = u;
          break;
        }
      }
      subscriptions = user != null && user['subscriptions'] != null
          ? List<String>.from(user['subscriptions'])
          : [];
    }
    context.read<PostBloc>().add(LoadPosts(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Лента новостей'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PostLoaded) {
              final posts = state.posts
                  .where((post) => subscriptions.contains(post['projectTitle']))
                  .toList();
              if (posts.isEmpty) {
                return Center(child: Text('Нет постов из ваших подписок'));
              }
              return ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (context, index) {
                  final post = posts[index];
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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/project',
                        arguments: {
                          'title': post['projectTitle'],
                          'ownerEmail': post['ownerEmail'],
                          'ownerNickname': post['ownerNickname'],
                          'description': post['projectDescription'],
                        },
                      );
                    },
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
    );
  }
}
