// lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/post_bloc.dart';
import '../../blocs/post_event.dart';
import '../../blocs/post_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
// Загружаем все посты при инициализации
    context
        .read<PostBloc>()
        .add(LoadPosts('')); // Пустая строка - загрузить все посты
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
              final posts = state.posts;
              if (posts.isEmpty) {
                return Center(child: Text('Постов пока нет'));
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
                          onPressed: () {}, // Пока без функционала
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down_alt_outlined),
                          onPressed: () {}, // Пока без функционала
                        ),
                        TextButton(
                          onPressed: () {
// Переход к комментариям (пока без функционала)
                          },
                          child: Text('Комментарии'),
                        ),
                      ],
                    ),
                    onTap: () {
// Переход на страницу сообщества
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
