import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscribeToProject extends SubscriptionEvent {
  final String userEmail;
  final String projectTitle;

  const SubscribeToProject(this.userEmail, this.projectTitle);

  @override
  List<Object?> get props => [userEmail, projectTitle];
}

class UnsubscribeFromProject extends SubscriptionEvent {
  final String userEmail;
  final String projectTitle;

  const UnsubscribeFromProject(this.userEmail, this.projectTitle);

  @override
  List<Object?> get props => [userEmail, projectTitle];
}

class LoadSubscriptions extends SubscriptionEvent {
  final String userEmail;

  const LoadSubscriptions(this.userEmail);

  @override
  List<Object?> get props => [userEmail];
}
