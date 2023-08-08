import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/model/profile.dart';
import 'package:reslate/model/signOut.dart';
import 'package:reslate/screen/authentication/login.dart';

import '../model/getDocument.dart';

class menuPage extends StatefulWidget {
  final Profile profile;
  const menuPage({required this.profile, Key? key}) : super(key: key);

  @override
  State<menuPage> createState() => _menuPageState();
}

class _menuPageState extends State<menuPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  firebaseDoc firebasedoc = firebaseDoc();

  late DocumentReference firebaseDocument;
  signOut signout = signOut();

  // void initState() {
  //   super.initState();
  //   getProfile();
  //   print('profile.data = ${profile.data}');
  // }

  // Future<void> getProfile() async {
  //   try {
  //     var docID = await firebasedoc.getDocumentId();
  //     if (docID == null) {
  //       firebaseDocument =
  //           await FirebaseFirestore.instance.collection('Profile').doc();
  //     } else {
  //       firebaseDocument = await FirebaseFirestore.instance
  //           .collection('Profile')
  //           .doc('$docID');
  //     }
  //     getDocumentData();
  //   } catch (e) {
  //     print('Error initializing page: $e');
  //   }
  // }

  // void getDocumentData() async {
  //   DocumentSnapshot documentSnapshot = await firebaseDocument.get();
  //   if (documentSnapshot.exists) {
  //     Map<String, dynamic>? data =
  //         await documentSnapshot.data() as Map<String, dynamic>?;

  //     if (data != null) {
  //       username = await data['Username'];
  //       email = await data['Email'];
  //       words = await data['words'];
  //       print(data);
  //     } else {
  //       print('Data is null or not a Map<String, dynamic>');
  //     }
  //   } else {
  //     print('Document does not exist');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? data = widget.profile.data;
    var username = data?['Username'];
    var email = data?['Email'];
    var words = data?['wordLength'];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 120, 10, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              return CircleAvatar(
                backgroundColor: Colors.blueGrey,
                radius: 30,
                child: Text(
                  '${words ?? '0'}',
                  style: TextStyle(fontSize: 25),
                ),
              );
            }),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Text(
                  'Username : ${username ?? 'Loading...'}\nEmail : ${email ?? 'Loading...'}',
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
