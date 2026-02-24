part of 'password_visibility_bloc.dart';

sealed class PasswordVisibilityEvent extends Equatable {
  const PasswordVisibilityEvent();

  @override
  List<Object> get props => [];
}

class TogglePasswordVisibilityEvent extends PasswordVisibilityEvent {}

class ToggleConfirmPasswordVisibilityEvent extends PasswordVisibilityEvent {}
