import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<String> subscriptions;

  const SubscriptionLoaded(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionChanged extends SubscriptionState {
  final bool isSubscribed;

  const SubscriptionChanged(this.isSubscribed);

  @override
  List<Object?> get props => [isSubscribed];
}
