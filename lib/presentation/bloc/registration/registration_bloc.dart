import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc() : super(RegistrationInitial()) {
    on<UserRegistrationEvent>(userRegistrationEvent);
  }

  FutureOr<void> userRegistrationEvent(
    UserRegistrationEvent event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(UserRegistrationLoadingState());
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );

      if (credential.user != null) {
        // You can also add full name update logic if needed
        await credential.user!.updateDisplayName(event.fullName);

        final userModel = UserModel(
          uid: credential.user!.uid,
          fullName: event.fullName,
          email: event.email,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        emit(
          UserRegistrationSuccessState(
            message: 'Account created successfully!',
          ),
        );
      } else {
        emit(
          UserRegistrationErrorState(
            errorMessage: 'Unable to create account. Please try again.',
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Unable to create account. Please try again.';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      emit(UserRegistrationErrorState(errorMessage: errorMessage));
    } catch (e) {
      emit(UserRegistrationErrorState(errorMessage: e.toString()));
    }
  }
}
