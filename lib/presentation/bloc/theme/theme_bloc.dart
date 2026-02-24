import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final themeModeStr = doc.data()?['themeMode'];
            if (themeModeStr == 'dark') {
              emit(ThemeState(ThemeMode.dark));
            } else if (themeModeStr == 'light') {
              emit(ThemeState(ThemeMode.light));
            } else {
              emit(ThemeState(ThemeMode.system)); // or default ThemeMode.dark/light based on system
            }
          }
        } catch (e) {
          // ignore
        }
      }
    });

    on<ChangeThemeEvent>((event, emit) async {
      emit(ThemeState(event.themeMode));
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String themeStr = 'system';
        if (event.themeMode == ThemeMode.dark) themeStr = 'dark';
        else if (event.themeMode == ThemeMode.light) themeStr = 'light';
        
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'themeMode': themeStr,
          });
        } catch (e) {
          // ignore
        }
      }
    });
  }
}
