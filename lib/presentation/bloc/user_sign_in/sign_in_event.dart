part of 'sign_in_bloc.dart';

@immutable
sealed class SignInEvent {}

class UserSignInEvent extends SignInEvent {
  final String email;
  final String password;

  UserSignInEvent({required this.email, required this.password});
}

class ToggleSignInPasswordVisibilityEvent extends SignInEvent {}
