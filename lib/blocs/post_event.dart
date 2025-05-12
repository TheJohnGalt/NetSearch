// lib/blocs/post_event.dart

abstract class PostEvent {}

class LoadPosts extends PostEvent {
  final String projectTitle;

  LoadPosts(this.projectTitle);
}

class AddPost extends PostEvent {
  final String projectTitle;
  final String content;

  AddPost(this.projectTitle, this.content);
}
