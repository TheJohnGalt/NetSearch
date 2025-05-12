// lib/blocs/post_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Box postsBox = Hive.box('postsBox');
  final Box projectsBox = Hive.box('projectsBox');

  PostBloc() : super(PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<AddPost>(_onAddPost);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      final allPosts = postsBox.values.cast<Map>().toList();

      List<Map> filteredPosts;

      if (event.projectTitle.isEmpty) {
        // Загрузка всех постов с дополнительными данными из проектов
        filteredPosts = allPosts.map((post) {
          final project = projectsBox.values.cast<Map>().firstWhere(
              (proj) => proj['title'] == post['projectTitle'],
              orElse: () => {});

          return {
            ...post,
            'ownerEmail': project['ownerEmail'] ?? '',
            'ownerNickname': project['ownerNickname'] ?? 'не известен',
            'projectDescription': project['description'] ?? '',
          };
        }).toList();
      } else {
        // Загрузка постов конкретного проекта
        filteredPosts = allPosts.where((p) => p['projectTitle'] == event.projectTitle).map((post) {
          final project = projectsBox.values.cast<Map>().firstWhere(
              (proj) => proj['title'] == post['projectTitle'],
              orElse: () => {});

          return {
            ...post,
            'ownerEmail': project['ownerEmail'] ?? '',
            'ownerNickname': project['ownerNickname'] ?? 'не известен',
            'projectDescription': project['description'] ?? '',
          };
        }).toList();
      }

      // Можно отсортировать по времени добавления, если есть поле времени (пока нет)
      emit(PostLoaded(filteredPosts));
    } catch (e) {
      emit(PostError('Ошибка загрузки постов'));
    }
  }

  Future<void> _onAddPost(AddPost event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      await postsBox.add({
        'projectTitle': event.projectTitle,
        'content': event.content,
      });

      final allPosts = postsBox.values.cast<Map>().toList();

      List<Map> filteredPosts = allPosts.where((p) => p['projectTitle'] == event.projectTitle).map((post) {
        final project = projectsBox.values.cast<Map>().firstWhere(
            (proj) => proj['title'] == post['projectTitle'],
            orElse: () => {});

        return {
          ...post,
          'ownerEmail': project['ownerEmail'] ?? '',
          'ownerNickname': project['ownerNickname'] ?? 'не известен',
          'projectDescription': project['description'] ?? '',
        };
      }).toList();

      emit(PostLoaded(filteredPosts));
    } catch (e) {
      emit(PostError('Ошибка при добавлении поста'));
    }
  }
}
