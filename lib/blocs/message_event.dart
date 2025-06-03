// lib/blocs/message_event.dart

abstract class MessageEvent {}

class LoadMessages extends MessageEvent {
  final String chatId;
  final String currentUserEmail;

  LoadMessages(this.chatId, this.currentUserEmail);
}

class SendMessage extends MessageEvent {
  final String chatId;
  final String senderEmail;
  final String content;

  SendMessage(this.chatId, this.senderEmail, this.content);
}
