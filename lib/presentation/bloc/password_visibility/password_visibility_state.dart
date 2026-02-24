part of 'password_visibility_bloc.dart';

class PasswordVisibilityState extends Equatable {
  final bool isPasswordHidden;
  final bool isConfirmPasswordHidden;

  const PasswordVisibilityState({
    this.isPasswordHidden = true,
    this.isConfirmPasswordHidden = true,
  });

  PasswordVisibilityState copyWith({
    bool? isPasswordHidden,
    bool? isConfirmPasswordHidden,
  }) {
    return PasswordVisibilityState(
      isPasswordHidden: isPasswordHidden ?? this.isPasswordHidden,
      isConfirmPasswordHidden:
          isConfirmPasswordHidden ?? this.isConfirmPasswordHidden,
    );
  }

  @override
  List<Object> get props => [isPasswordHidden, isConfirmPasswordHidden];
}
