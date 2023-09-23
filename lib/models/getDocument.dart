import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reslate/models/profile.dart';

class firebaseDoc {
  Profile profile = Profile();
  late DocumentReference firebaseDocument;
  Map<String, dynamic>? data, document;
  // For email login
  var userEmail = FirebaseAuth.instance.currentUser?.email;

// For Google sign-in
  var userUID = FirebaseAuth.instance.currentUser?.uid;
  var username, email;

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
      return userId;
    } catch (e) {
      print('Error getting document ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      // Get the current user ID or a random ID
      var docID = await getDocumentId();
      // ดึงข้อมูลได้แต่ยังเอา document id มาที่หน้า menu ไม่ได้
      if (docID == null) {
        firebaseDocument =
            await FirebaseFirestore.instance.collection('Profile').doc();
      } else {
        firebaseDocument = await FirebaseFirestore.instance
            .collection('Profile')
            .doc('$docID');
      }
      document = getDocumentData() as Map<String, dynamic>?;
      return document;
    } catch (e) {
      print('Error initializing page: $e');
    }
  }

  Future<Map<String, dynamic>?> getDocumentData() async {
    DocumentSnapshot documentSnapshot = await firebaseDocument.get();
    if (documentSnapshot.exists) {
      data = await documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        username = await data?['Username'];
        email = await data?['Email'];
        return data;
      } else {
        print('Data is null or not a Map<String, dynamic>');
      }
    } else {
      print('Document does not exist');
    }
  }
}
