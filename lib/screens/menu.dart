import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/models/signOut.dart';
import 'package:reslate/screens/WordsCollection.dart';
import 'package:reslate/screens/authentication/login.dart';
import 'package:reslate/screens/notification.dart';

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
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
          child: ListView(
            children: [
              SizedBox(
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
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
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
              SizedBox(
                height: 90,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                      onPressed: () {
                        Get.to(
                          WordsCollection(sendData: (data) {
                            setState(() {
                              widget.profile.data = data;
                            });
                          }),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book,
                            color: Colors.blue,
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
                            color: Colors.blue,
                            size: 40,
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(
                height: 90,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                      onPressed: () {
                        Get.to(NotificationScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.yellow[700]!,
                            size: 40,
                          ),
                          Text(
                            '  Notification  ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.notifications_active,
                            color: Colors.yellow[700]!,
                            size: 40,
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(
                height: 90,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () async {
                      await Get.dialog(
                        AlertDialog(
                          backgroundColor: Colors.blue[100]!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          title: Text(
                            'Translate Words 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                              'Bookmark 10 words to unlock multiple choice mode.'),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: words >= 10 ? Colors.amber[500]! : Colors.grey,
                          size: 50,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Translate Words 1  ',
                              style: TextStyle(
                                fontSize: 16,
                                color: words >= 10 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 10 words to unlock multiple choice.',
                              style: TextStyle(
                                fontSize: 11,
                                color: words >= 10 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 200, // Adjust the width as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words != null
                                          ? (words > 10 ? 1.0 : words / 10)
                                          : 0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words >= 10
                                            ? Colors.green!
                                            : Colors.grey,
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${words > 10 ? 10 : words}/10',
                                  style: TextStyle(
                                    color: words >= 10
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () async {
                      await Get.dialog(
                        AlertDialog(
                          backgroundColor: Colors.blue[100]!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          title: Text(
                            'Translate Words 2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                              'bookmark 50 words to unlock review aids. When unlocked, You will receive aid 1 time. If you want more aids, you must answer 10 questions in a row correctly in the multiple choice mode.'),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: words >= 50 ? Colors.amber[500]! : Colors.grey,
                          size: 50,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Translate Words 2',
                              style: TextStyle(
                                fontSize: 16,
                                color: words >= 50 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 50 words to unlock aids.',
                              style: TextStyle(
                                fontSize: 11,
                                color: words >= 50 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 200, // Adjust the width as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words != null
                                          ? (words > 50 ? 1.0 : words / 50)
                                          : 0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words >= 50
                                            ? Colors.green!
                                            : Colors.grey,
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${words > 50 ? 50 : words}/50',
                                  style: TextStyle(
                                    color: words >= 50
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () async {
                      await Get.dialog(
                        AlertDialog(
                          backgroundColor: Colors.blue[100]!,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          title: Text(
                            'Translate Words 3',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                              'Bookmark 70 words to unlock match card mode.'),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    Get.back(); // Close the dialog
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: words >= 70 ? Colors.amber[500]! : Colors.grey,
                          size: 50,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Translate Words 3',
                              style: TextStyle(
                                fontSize: 16,
                                color: words >= 70 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 70 words to unlock match card.',
                              style: TextStyle(
                                fontSize: 11,
                                color: words >= 70 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: 200, // Adjust the width as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words != null
                                          ? (words > 70 ? 1.0 : words / 70)
                                          : 0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words >= 70
                                            ? Colors.green!
                                            : Colors.grey,
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${words > 70 ? 70 : words}/70',
                                  style: TextStyle(
                                    color: words >= 70
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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
