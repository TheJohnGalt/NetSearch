// lib/pages/home/project_create_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/project_bloc.dart';
import '../../blocs/project_event.dart';
import '../../blocs/project_state.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/auth_state.dart';

class ProjectCreatePage extends StatefulWidget {
  @override
  _ProjectCreatePageState createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String ownerEmail;
  late String ownerNickname;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      ownerEmail = args;
    } else {
      ownerEmail = '';
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      ownerNickname = authState.nickname;
    } else {
      ownerNickname = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать сообщество'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Название проекта'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание проекта'),
              maxLines: 4,
            ),
            SizedBox(height: 24),
            BlocConsumer<ProjectBloc, ProjectState>(
              listener: (context, state) {
                if (state is ProjectLoaded) {
                  Navigator.pop(context);
                } else if (state is ProjectError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProjectLoading) {
                  return CircularProgressIndicator();
                }
                return ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final description = _descriptionController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Введите название проекта')),
                      );
                      return;
                    }

                    context.read<ProjectBloc>().add(
                          AddProject(ownerEmail, ownerNickname, title, description),
                        );
                  },
                  child: Text('Создать'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
