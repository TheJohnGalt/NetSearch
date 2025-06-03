// lib/pages/home/messenger_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/chat_bloc.dart';
import '../../blocs/chat_event.dart';
import '../../blocs/chat_state.dart';

class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  late String currentUserEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserEmail = authState.email;
      context.read<ChatBloc>().add(LoadChats(currentUserEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мессенджер'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ChatLoaded) {
            if (state.chats.isEmpty) {
              return Center(child: Text('У вас нет переписок'));
            }
            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final participantsEmails =
                    List<String>.from(chat['participantsEmails']);
                final participantsNicknames =
                    List<String>.from(chat['participantsNicknames']);

                int otherIndex = participantsEmails
                    .indexWhere((email) => email != currentUserEmail);
                String otherNickname = otherIndex != -1
                    ? participantsNicknames[otherIndex]
                    : 'Неизвестный';

                final otherUserData = {
                  'email': participantsEmails[otherIndex],
                  'nickname': otherNickname,
                  'description': '',
                };

                return ListTile(
                  title: Text(otherNickname),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'chatId': chat.keys.isNotEmpty
                            ? chat['chatId'] ??
                                chat['id'] ??
                                chat['key'] ??
                                index
                            : index,
                        'otherUser': otherUserData,
                      },
                    );
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
