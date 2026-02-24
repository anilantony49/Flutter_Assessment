part of 'registration_bloc.dart';

@immutable
sealed class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class UserRegistrationLoadingState extends RegistrationState {}

class UserRegistrationSuccessState extends RegistrationState {
  final String message;

  UserRegistrationSuccessState({required this.message});
}

class UserRegistrationErrorState extends RegistrationState {
  final String errorMessage;

  UserRegistrationErrorState({required this.errorMessage});
}
