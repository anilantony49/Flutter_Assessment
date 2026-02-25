part of 'user_profile_bloc.dart';

@immutable
sealed class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}
class UserProfileUpdating extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserModel user;

  UserProfileLoaded({required this.user});
}

class UserProfileError extends UserProfileState {
  final String message;

  UserProfileError({required this.message});
}

class UserProfileUpdateSuccess extends UserProfileState {
  final String message;

  UserProfileUpdateSuccess({required this.message});
}
