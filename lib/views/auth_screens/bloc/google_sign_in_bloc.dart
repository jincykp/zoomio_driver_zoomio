import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/google_sign_in_event.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/google_sign_in_state.dart';

class GoogleSignInBloc extends Bloc<GoogleSignInEvent, GoogleSignInState> {
  GoogleSignInBloc() : super(GoogleSignInInitial()) {
    on<GoogleSignInEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
