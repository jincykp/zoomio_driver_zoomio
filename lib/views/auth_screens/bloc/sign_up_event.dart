// sign_up_event.dart
abstract class SignUpEvent {}

class SignUpButtonPressed extends SignUpEvent {
  final String email;
  final String password;

  SignUpButtonPressed({
    required this.email,
    required this.password,
  });
}
