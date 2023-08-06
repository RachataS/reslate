import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reslate/model/profile.dart';

class firebaseDoc {
  Profile profile = Profile();
  // For email login
  var userEmail = FirebaseAuth.instance.currentUser?.email;

// For Google sign-in
  var userUID = FirebaseAuth.instance.currentUser?.uid;

  Future<String?> getDocumentId() async {
    try {
      String? userId;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      String? userUID = FirebaseAuth.instance.currentUser?.uid;

      if (userEmail != null) {
        // Query the collection for the user with the specified email
        var querySnapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .where('Email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If the user with the specified email exists, get their document ID
          userId = querySnapshot.docs.first.id;
        }
      } else if (userUID != null) {
        // Query the collection for the user with the specified UID
        var querySnapshot = await FirebaseFirestore.instance
            .collection('Profile')
            .where('Email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If the user with the specified UID exists, get their document ID
          userId = querySnapshot.docs.first.id;
        }
      }
      profile.docID = userId;
      print(profile.docID);
    } catch (e) {
      print('Error getting document ID: $e');
      return null;
    }
  }
}
