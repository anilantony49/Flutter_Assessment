import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(SignInInitial()) {
    on<UserSignInEvent>(userSignInEvent);
    on<ToggleSignInPasswordVisibilityEvent>(
      toggleSignInPasswordVisibilityEvent,
    );
  }

  FutureOr<void> userSignInEvent(
    UserSignInEvent event,
    Emitter<SignInState> emit,
  ) async {
    // Keep current password visibility state
    final isHidden =
        state is SignInBaseState
            ? (state as SignInBaseState).isPasswordHidden
            : true;

    emit(UserSignInLoadingState(isPasswordHidden: isHidden));
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        emit(
          UserSignInSuccessState(
            message: 'Login successful!',
            isPasswordHidden: isHidden,
          ),
        );
      } else {
        emit(
          UserSignInErrorState(
            errorMessage: 'Unable to login. Please try again.',
            isPasswordHidden: isHidden,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Unable to login. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      emit(
        UserSignInErrorState(
          errorMessage: errorMessage,
          isPasswordHidden: isHidden,
        ),
      );
    } catch (e) {
      emit(
        UserSignInErrorState(
          errorMessage: e.toString(),
          isPasswordHidden: isHidden,
        ),
      );
    }
  }

  FutureOr<void> toggleSignInPasswordVisibilityEvent(
    ToggleSignInPasswordVisibilityEvent event,
    Emitter<SignInState> emit,
  ) {
    bool currentIsHidden = true;
    if (state is SignInBaseState) {
      currentIsHidden = (state as SignInBaseState).isPasswordHidden;
    }

    emit(SignInInitial(isPasswordHidden: !currentIsHidden));
  }
}
