// google_sign_in_state.dart
import 'package:firebase_auth/firebase_auth.dart';

abstract class GoogleSignInState {}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInLoading extends GoogleSignInState {}

class GoogleSignInSuccess extends GoogleSignInState {
  final User user;

  GoogleSignInSuccess(this.user);
}

class GoogleSignInFailure extends GoogleSignInState {
  final String errorMessage;

  GoogleSignInFailure(this.errorMessage);
}
