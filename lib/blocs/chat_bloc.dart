import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Box chatsBox = Hive.box('chatsBox');

  ChatBloc() : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<AddChat>(_onAddChat);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final allChats = chatsBox.values.cast<Map<String, dynamic>>().toList();
      final userChats = allChats.where((chat) =>
          chat['participantsEmails'].contains(event.currentUserEmail)).toList();
      emit(ChatLoaded(userChats));
    } catch (e) {
      emit(ChatError('Ошибка загрузки переписок'));
    }
  }

  Future<void> _onAddChat(AddChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final allChats = chatsBox.toMap();

      int? existingKey;
      allChats.forEach((key, chat) {
        final participants = chat['participantsEmails'] as List<dynamic>;
        if (participants.contains(event.currentUserEmail) &&
            participants.contains(event.otherUser['email'])) {
          existingKey = key;
        }
      });

      if (existingKey == null) {
        final newKey = await chatsBox.add({
          'participantsEmails': [event.currentUserEmail, event.otherUser['email']],
          'participantsNicknames': [event.currentUserEmail, event.otherUser['nickname']],
          'createdAt': DateTime.now().toIso8601String(),
        });
        existingKey = newKey;
      }

      final updatedChats = chatsBox.values.cast<Map<String, dynamic>>().toList()
          .where((chat) => (chat['participantsEmails'] as List).contains(event.currentUserEmail))
          .toList();

      emit(ChatLoaded(updatedChats));

      _chatIdCompleter?.complete(existingKey);
      _chatIdCompleter = null;
    } catch (e) {
      emit(ChatError('Ошибка создания переписки'));
      _chatIdCompleter?.completeError(e);
      _chatIdCompleter = null;
    }
  }

  Completer<int>? _chatIdCompleter;

  Future<int> createOrGetChatId(String currentUserEmail, Map<String, dynamic> otherUser) {
    _chatIdCompleter = Completer<int>();
    add(AddChat(currentUserEmail, otherUser));
    return _chatIdCompleter!.future;
  }
}
