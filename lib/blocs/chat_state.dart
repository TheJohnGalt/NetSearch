// lib/blocs/chat_state.dart

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Map<String, dynamic>> chats;

  ChatLoaded(this.chats);
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
