import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthServices authServices;

  SignUpBloc(this.authServices) : super(SignUpInitial()) {
    // Register the event handler using on<Event>
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  // Event handler for SignUpButtonPressed
  Future<void> _onSignUpButtonPressed(
    SignUpButtonPressed event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final user = await authServices.createAccountWithEmail(
        event.email,
        event.password,
      );

      if (user != null) {
        emit(SignUpSuccess(user));
      } else {
        emit(SignUpFailure(
            "The email address is already in use by another account"));
      }
    } catch (e) {
      emit(SignUpFailure("Error: $e"));
    }
  }
}
