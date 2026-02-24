part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileEvent {}

class FetchUserProfileEvent extends UserProfileEvent {
  final String uid;

  FetchUserProfileEvent({required this.uid});
}
