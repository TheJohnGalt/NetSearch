import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';
import '../../blocs/message_bloc.dart';
import '../../blocs/message_event.dart';
import '../../blocs/message_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String chatId;
  late String currentUserEmail;
  late Map<String, dynamic> otherUser;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    chatId = args['chatId'].toString();
    otherUser = args['otherUser'];

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      currentUserEmail = authState.email;
    } else {
      currentUserEmail = '';
    }

    context.read<MessageBloc>().add(LoadMessages(chatId, currentUserEmail));
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context
        .read<MessageBloc>()
        .add(SendMessage(chatId, currentUserEmail, content));
    _messageController.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUser['nickname'] ?? 'Чат'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MessageBloc, MessageState>(
              builder: (context, state) {
                if (state is MessageLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is MessageLoaded) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return Center(child: Text('Нет сообщений'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderEmail'] == currentUserEmail;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.lightGreen[200]
                                : Colors.lightBlue[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['content'] ?? ''),
                        ),
                      );
                    },
                  );
                } else if (state is MessageError) {
                  return Center(child: Text(state.message));
                }
                return SizedBox.shrink();
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Введите сообщение',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                    ),
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
