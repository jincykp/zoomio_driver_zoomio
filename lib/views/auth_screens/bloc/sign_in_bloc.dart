import 'package:bloc/bloc.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthServices authServices;

  SignInBloc(this.authServices) : super(SignInInitial()) {
    on<SignInButtonPressed>((event, emit) async {
      emit(SignInLoading());
      try {
        final user = await authServices.loginAccountWithEmail(
          event.email.trim(),
          event.password.trim(),
        );

        if (user != null) {
          emit(SignInSuccess());
        } else {
          emit(SignInFailure("Invalid email or password"));
        }
      } catch (e) {
        emit(SignInFailure(e.toString()));
      }
    });
  }
}
