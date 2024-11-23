import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// Define the possible theme states
enum ThemeModeState { light, dark }

// Create a ThemeCubit to manage the theme state
class ThemeCubit extends Cubit<ThemeModeState> {
  ThemeCubit() : super(ThemeModeState.light); // Default to light theme

  void toggleTheme() {
    if (state == ThemeModeState.light) {
      emit(ThemeModeState.dark); // Switch to dark theme
    } else {
      emit(ThemeModeState.light); // Switch to light theme
    }
  }
}
