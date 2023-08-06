import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/model/profile.dart';
import 'package:reslate/model/signOut.dart';
import 'package:reslate/screen/authentication/login.dart';

class menuPage extends StatefulWidget {
  const menuPage({super.key});

  @override
  State<menuPage> createState() => _menuPageState();
}

class _menuPageState extends State<menuPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  late DocumentReference firebaseDoc;
  Profile profile = Profile();
  signOut signout = signOut();

  void initState() {
    super.initState();
    // Get the current user ID or a random ID
    String? docID;

    // ดึงข้อมูลได้แต่ยังเอา document id มาที่หน้า menu ไม่ได้
    if (docID == null) {
      firebaseDoc = FirebaseFirestore.instance.collection('Profile').doc();
    } else {
      firebaseDoc = FirebaseFirestore.instance.collection('Profile').doc(docID);
    }

    print('Document ID = ${docID}');
    getDocumentData();
  }

  void getDocumentData() async {
    DocumentSnapshot documentSnapshot = await firebaseDoc.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        // Access specific fields by their keys
        var username = data['Username'];
        var email = data['Email'];

        print("Username: $username");
        print("Email: $email");
      } else {
        print('Data is null or not a Map<String, dynamic>');
      }
    } else {
      print('Document does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 120, 10, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(
                '10',
                style: TextStyle(fontSize: 25),
              ),
              radius: 30,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  'Username : xxxxx\nEmail : xxxxx',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            logOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return loginPage();
            }));
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.logout),
      ),
    );
  }

  Future<void> logOut() async {
    try {
      await signout.logoutWithEmail();
    } catch (e) {
      print(e);
    }
    try {
      await signout.logoutWithGoogle();
    } catch (e) {
      print(e);
    }
  }
}
