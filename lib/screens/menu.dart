import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/models/signOut.dart';
import 'package:reslate/screens/WordsCollection.dart';
import 'package:reslate/screens/authentication/login.dart';

import '../controllers/getDocument.dart';

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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[600]!,
            Colors.blue[300]!,
            Colors.blue[100]!,
            // Colors.blue[50]!,
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 90,
                  child: Card(
                    // color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.all(5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
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
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: SizedBox(
                  height: 90,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.all(5),
                    child: TextButton(
                        onPressed: () {
                          Get.to(
                            WordsCollection(),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book,
                              color: Colors.black,
                              size: 40,
                            ),
                            Text(
                              '  Words Collection  ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Icon(
                              Icons.book,
                              color: Colors.black,
                              size: 40,
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
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
