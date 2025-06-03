import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final Box messagesBox = Hive.box('messagesBox');

  MessageBloc() : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final allMessages = messagesBox.values.cast<Map<String, dynamic>>().toList();
      final chatIdStr = event.chatId.toString();
      final chatMessages = allMessages.where((msg) => msg['chatId'].toString() == chatIdStr).toList();
      chatMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      emit(MessageLoaded(chatMessages));
    } catch (e) {
      emit(MessageError('Ошибка загрузки сообщений'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await messagesBox.add({
        'chatId': event.chatId.toString(),
        'senderEmail': event.senderEmail,
        'content': event.content,
        'timestamp': timestamp,
      });

      final allMessages = messagesBox.values.cast<Map<String, dynamic>>().toList();
      final chatIdStr = event.chatId.toString();
      final chatMessages = allMessages.where((msg) => msg['chatId'].toString() == chatIdStr).toList();
      chatMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

      emit(MessageLoaded(chatMessages));
    } catch (e) {
      emit(MessageError('Ошибка отправки сообщения'));
    }
  }
}
