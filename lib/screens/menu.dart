import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/models/signOut.dart';
import 'package:reslate/screens/authentication/login.dart';

import '../models/getDocument.dart';

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
                backgroundColor: Colors.blue[400],
                radius: 30,
                child: Text(
                  '${words ?? '0'}',
                  style: TextStyle(fontSize: 25, color: Colors.white),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          backgroundColor: Colors.blue,
          onPressed: () async {
            // Show a dialog to confirm logout
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.blue[100]!,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        40), // Adjust the radius as needed
                  ),
                  title: Text(
                    "Logout",
                    textAlign: TextAlign.center,
                  ),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close the dialog
                            try {
                              await logOut();
                              Get.to(loginPage(),
                                  transition: Transition.topLevel);
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
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
