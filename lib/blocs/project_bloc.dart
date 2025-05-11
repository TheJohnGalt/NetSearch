import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final Box projectsBox = Hive.box('projectsBox');

  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<AddProject>(_onAddProject);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());

    try {
      final allProjects = projectsBox.values.cast<Map>().toList();
      final userProjects = allProjects.where((p) => p['ownerEmail'] == event.ownerEmail).toList();

      emit(ProjectLoaded(userProjects));
    } catch (e) {
      emit(ProjectError('Ошибка загрузки проектов'));
    }
  }

  Future<void> _onAddProject(AddProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());

    try {
      await projectsBox.add({
        'ownerEmail': event.ownerEmail,
        'title': event.title,
        'description': event.description,
      });

      // После добавления обновляем список
      final allProjects = projectsBox.values.cast<Map>().toList();
      final userProjects = allProjects.where((p) => p['ownerEmail'] == event.ownerEmail).toList();

      emit(ProjectLoaded(userProjects));
    } catch (e) {
      emit(ProjectError('Ошибка при добавлении проекта'));
    }
  }
}
