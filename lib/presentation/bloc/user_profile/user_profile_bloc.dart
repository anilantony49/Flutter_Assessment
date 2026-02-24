import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/models/user_model.dart';
import 'package:meta/meta.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial()) {
    on<FetchUserProfileEvent>(_onFetchUserProfile);
  }

  FutureOr<void> _onFetchUserProfile(
    FetchUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final doc = await FirebaseFirestore.instance
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
      emit(UserProfileError(message: 'Failed to fetch user profile: $e'));
    }
  }
}
