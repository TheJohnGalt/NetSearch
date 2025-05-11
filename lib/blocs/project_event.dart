abstract class ProjectEvent {}

class LoadProjects extends ProjectEvent {
  final String ownerEmail;

  LoadProjects(this.ownerEmail);
}

class AddProject extends ProjectEvent {
  final String ownerEmail;
  final String title;
  final String description;

  AddProject(this.ownerEmail, this.title, this.description);
}
