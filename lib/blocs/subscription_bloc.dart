import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final Box usersBox = Hive.box('usersBox');

  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<SubscribeToProject>(_onSubscribe);
    on<UnsubscribeFromProject>(_onUnsubscribe);
    on<LoadSubscriptions>(_onLoadSubscriptions);
  }

  MapEntry<dynamic, Map>? _findUserEntry(String email) {
    final entries = usersBox.toMap().entries;
    for (final entry in entries) {
      final u = entry.value as Map;
      if (u['email'] == email) return MapEntry(entry.key, u);
    }
    return null;
  }

  void _onSubscribe(SubscribeToProject event, Emitter<SubscriptionState> emit) async {
    final userEntry = _findUserEntry(event.userEmail);
    if (userEntry != null) {
      final user = Map<String, dynamic>.from(userEntry.value);
      final subs = user['subscriptions'] is List
          ? List<String>.from(user['subscriptions'] as List)
          : <String>[];
      if (!subs.contains(event.projectTitle)) {
        subs.add(event.projectTitle);
        user['subscriptions'] = subs;
        await usersBox.put(userEntry.key, user);
      }
      emit(SubscriptionChanged(true));
    }
  }

  void _onUnsubscribe(UnsubscribeFromProject event, Emitter<SubscriptionState> emit) async {
    final userEntry = _findUserEntry(event.userEmail);
    if (userEntry != null) {
      final user = Map<String, dynamic>.from(userEntry.value);
      final subs = user['subscriptions'] is List
          ? List<String>.from(user['subscriptions'] as List)
          : <String>[];
      if (subs.contains(event.projectTitle)) {
        subs.remove(event.projectTitle);
        user['subscriptions'] = subs;
        await usersBox.put(userEntry.key, user);
      }
      emit(SubscriptionChanged(false));
    }
  }

  void _onLoadSubscriptions(LoadSubscriptions event, Emitter<SubscriptionState> emit) {
    final userEntry = _findUserEntry(event.userEmail);
    if (userEntry != null) {
      final user = Map<String, dynamic>.from(userEntry.value);
      final subs = user['subscriptions'] is List
          ? List<String>.from(user['subscriptions'] as List)
          : <String>[];
      emit(SubscriptionLoaded(subs));
    } else {
      emit(SubscriptionLoaded([]));
    }
  }
}
