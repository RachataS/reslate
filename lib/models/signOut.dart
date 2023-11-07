import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class signOut {
  Future<void> logoutWithEmail() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Show a message or perform any other actions after successful logout
    } catch (e) {
      // Handle any error that occurs during logout
      print("Error during email logout: $e");
    }
  }

  Future<void> logoutWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      // Show a message or perform any other actions after successful logout
    } catch (e) {
      // Handle any error that occurs during logout
      print("Error during Google logout: $e");
    }
  }
}
