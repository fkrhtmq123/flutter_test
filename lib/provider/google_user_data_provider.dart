import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData with ChangeNotifier {
  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  setCurrentUser(GoogleSignInAccount? user) {
    _currentUser = user;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
