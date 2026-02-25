import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/data/models/user_model.dart';
import 'package:flutter_assesment/utils/error_handlers.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  FutureOr<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileUpdating());
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .update({'fullName': event.fullName});

      // Emit success state, then fetch profile again to update the UI
      emit(UserProfileUpdateSuccess(message: 'Profile updated successfully!'));
      add(FetchUserProfileEvent(uid: event.uid, isRefresh: true));
    } catch (e) {
      emit(UserProfileError(message: ErrorHandler.getMessage(e)));
    }
  }

  FutureOr<void> _onFetchUserProfile(
    FetchUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(UserProfileLoading());
    }

    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(event.uid)
              .get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data(), doc.id);
        emit(UserProfileLoaded(user: userModel));
      } else {
        emit(UserProfileError(message: 'User profile not found.'));
      }
    } catch (e) {
      emit(UserProfileError(message: ErrorHandler.getMessage(e)));
    }
  }
}
