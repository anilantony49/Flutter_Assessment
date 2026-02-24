part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState {}

abstract class SignInBaseState extends SignInState {
  final bool isPasswordHidden;

  SignInBaseState({this.isPasswordHidden = true});
}

class SignInInitial extends SignInBaseState {
  SignInInitial({super.isPasswordHidden = true});
}

class UserSignInLoadingState extends SignInBaseState {
  UserSignInLoadingState({super.isPasswordHidden = true});
}

class UserSignInSuccessState extends SignInBaseState {
  final String message;

  UserSignInSuccessState({required this.message, super.isPasswordHidden = true});
}

class UserSignInErrorState extends SignInBaseState {
  final String errorMessage;

  UserSignInErrorState({required this.errorMessage, super.isPasswordHidden = true});
}
