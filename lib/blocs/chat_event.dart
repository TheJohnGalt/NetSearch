// lib/blocs/chat_event.dart

abstract class ChatEvent {}

class LoadChats extends ChatEvent {
  final String currentUserEmail;

  LoadChats(this.currentUserEmail);
}

class AddChat extends ChatEvent {
  final String currentUserEmail;
  final Map<String, dynamic> otherUser;

  AddChat(this.currentUserEmail, this.otherUser);
}
