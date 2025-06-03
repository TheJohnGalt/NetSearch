// lib/blocs/search_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Box usersBox = Hive.box('usersBox');

  SearchBloc() : super(SearchInitial()) {
    on<SearchRequested>(_onSearchRequested);
  }

  Future<void> _onSearchRequested(SearchRequested event, Emitter<SearchState> emit) async {
    emit(SearchLoading());

    await Future.delayed(Duration(milliseconds: 300)); // имитация задержки

    final query = event.query.toLowerCase();
    final users = usersBox.values.cast<Map>().toList();

    final results = users.where((user) {
      final email = (user['email'] ?? '').toString().toLowerCase();
      final nickname = (user['nickname'] ?? '').toString().toLowerCase();
      return email.contains(query) || nickname.contains(query);
    }).toList();

    if (results.isEmpty) {
      emit(SearchError('Пользователи не найдены'));
    } else {
      emit(SearchLoaded(results));
    }
  }
}
