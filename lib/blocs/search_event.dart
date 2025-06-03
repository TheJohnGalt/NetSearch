// lib/blocs/search_event.dart

abstract class SearchEvent {}

class SearchRequested extends SearchEvent {
  final String query;

  SearchRequested(this.query);
}
