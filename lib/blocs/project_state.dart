abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Map> projects;

  ProjectLoaded(this.projects);
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError(this.message);
}
