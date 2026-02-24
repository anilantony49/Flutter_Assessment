part of 'registration_bloc.dart';

@immutable
sealed class RegistrationEvent {}

class UserRegistrationEvent extends RegistrationEvent {
  final String fullName;
  final String email;
  final String password;

  UserRegistrationEvent({
    required this.fullName,
    required this.email,
    required this.password,
  });
}
