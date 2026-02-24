import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'password_visibility_event.dart';
part 'password_visibility_state.dart';

class PasswordVisibilityBloc extends Bloc<PasswordVisibilityEvent, PasswordVisibilityState> {
  PasswordVisibilityBloc() : super(const PasswordVisibilityState()) {
    on<TogglePasswordVisibilityEvent>((event, emit) {
      emit(state.copyWith(isPasswordHidden: !state.isPasswordHidden));
    });

    on<ToggleConfirmPasswordVisibilityEvent>((event, emit) {
      emit(
        state.copyWith(isConfirmPasswordHidden: !state.isConfirmPasswordHidden),
      );
    });
  }
}
