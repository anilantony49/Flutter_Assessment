part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileEvent {}

class FetchUserProfileEvent extends UserProfileEvent {
  final String uid;
  final bool isRefresh;

  FetchUserProfileEvent({required this.uid, this.isRefresh = false});
}

class UpdateUserProfileEvent extends UserProfileEvent {
  final String uid;
  final String fullName;

  UpdateUserProfileEvent({required this.uid, required this.fullName});
}
