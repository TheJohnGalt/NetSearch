// lib/blocs/message_state.dart

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<Map<String, dynamic>> messages;

  MessageLoaded(this.messages);
}

class MessageError extends MessageState {
  final String message;

  MessageError(this.message);
}
