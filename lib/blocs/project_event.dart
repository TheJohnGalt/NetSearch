// lib/blocs/project_event.dart

abstract class ProjectEvent {}

class LoadProjects extends ProjectEvent {
  final String ownerEmail;

  LoadProjects(this.ownerEmail);
}

class AddProject extends ProjectEvent {
  final String ownerEmail;
  final String ownerNickname; // Добавляем ник владельца
  final String title;
  final String description;

  AddProject(this.ownerEmail, this.ownerNickname, this.title, this.description);
}
