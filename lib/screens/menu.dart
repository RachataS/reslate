import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/models/signOut.dart';
import 'package:reslate/screens/WordsCollection.dart';
import 'package:reslate/screens/authentication/login.dart';
import 'package:reslate/screens/notification.dart';

class MenuPage extends StatefulWidget {
  final Profile profile;
  const MenuPage({required this.profile, Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late double _cardHeight;
  signOut signout = signOut();

  @override
  void initState() {
    super.initState();
    _cardHeight = 90.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust card height based on screen size
    if (screenWidth < 600) {
      _cardHeight = 90.0;
    } else if (screenWidth < 900) {
      _cardHeight = 120.0;
    } else {
      _cardHeight = 150.0;
    }

    Map<String, dynamic>? data = widget.profile.data;
    var username = data?['Username'];
    var email = data?['Email'];
    var words = data?['wordLength'];
    var aids = data?['aids'];

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[600]!,
            Colors.blue[300]!,
            Colors.blue[100]!,
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
          child: ListView(
            children: [
              SizedBox(
                height: _cardHeight,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.all(5),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue[400],
                          radius: 30,
                          child: Icon(
                            Icons.account_circle_rounded,
                            color: Colors.white,
                            size: 55,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: Text(
                              '${username != null ? username!.split(' ')[0] : 'Loading...'}\n${email ?? 'Loading...'}',
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
                height: _cardHeight,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '  Vocabulary Collection  ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '  you have ${words ?? '0'} words  ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.book,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: _cardHeight,
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
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   height: _cardHeight,
              //   child: Card(
              //     color: Colors.white,
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(15)),
              //     margin: const EdgeInsets.all(5),
              //     child: TextButton(
              //       onPressed: () {
              //         //open manual book
              //       },
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Icon(
              //             Icons.menu_book_rounded,
              //             color: Colors.green,
              //             size: 40,
              //           ),
              //           Text(
              //             '  manual  ',
              //             style: TextStyle(
              //               fontSize: 16,
              //               color: Colors.black,
              //             ),
              //           ),
              //           Icon(
              //             Icons.menu_book_rounded,
              //             color: Colors.green,
              //             size: 40,
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(
                height: _cardHeight,
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
                              'บันทึกคำศัพท์ 10 คำเพื่อปลดล็อคแบบทดสอบแบบเลือกตอบ'),
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
                          color:
                              words! >= 10 ? Colors.amber[500]! : Colors.grey,
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
                                color:
                                    words! >= 10 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 10 words to unlock multiple choice.',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    words! >= 10 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // 50% of the screen width
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words! >= 10 ? 1.0 : words / 10,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words! >= 10
                                            ? Colors.green
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
                                  '${words! > 10 ? 10 : words}/10',
                                  style: TextStyle(
                                    color: words! >= 10
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
                height: _cardHeight,
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
                            'Translate Words 2\n${aids}/3',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                              '- บันทึกคำศัพท์ 50 คำเพื่อปลดล็อคตัวช่วย\n- รับตัวช่วยเพิ่ม 1 ครั้งทุกๆการตอบคำถามถูกติดกัน 10 ข้อในแบบทดสอบเลือกตอบ\n- รับตัวช่วยเพิ่ม 1 ครั้งทุกๆการจับคู่การ์ด 8 คู่'),
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
                          color:
                              words! >= 50 ? Colors.amber[500]! : Colors.grey,
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
                                color:
                                    words! >= 50 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 50 words to unlock aids.',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    words! >= 50 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // 50% of the screen width
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words! >= 50 ? 1.0 : words / 50,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words! >= 50
                                            ? Colors.green
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
                                  '${words! > 50 ? 50 : words}/50',
                                  style: TextStyle(
                                    color: words! >= 50
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
                height: _cardHeight,
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
                              'บันทึกคำศัพท์ 70 คำเพื่อปลดล็อคแบบทดสอบจับคู่การ์ด'),
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
                          color:
                              words! >= 70 ? Colors.amber[500]! : Colors.grey,
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
                                color:
                                    words! >= 70 ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Bookmark 70 words to unlock match card.',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    words! >= 70 ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 10,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the outer shape
                                    color: Colors.grey[300],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Adjust this for the inner shape
                                    child: LinearProgressIndicator(
                                      value: words! >= 70 ? 1.0 : words / 70,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        words! >= 70
                                            ? Colors.green
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
                                  '${words! > 70 ? 70 : words}/70',
                                  style: TextStyle(
                                    color: words! >= 70
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
      floatingActionButton: FloatingActionButton(
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
                  borderRadius:
                      BorderRadius.circular(40), // Adjust the radius as needed
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
