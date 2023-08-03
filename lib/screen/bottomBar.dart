import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/screen/menu.dart';
import 'package:reslate/screen/quize.dart';
import 'package:reslate/screen/translate/Translate.dart';

import '../model/profile.dart';

class bottombar extends StatefulWidget {
  const bottombar({Key? key}) : super(key: key);

  @override
  State<bottombar> createState() => _bottombarState();
}

class _bottombarState extends State<bottombar> {
  int currentIndex = 0;
  Profile profile = Profile();
  translate_screen home = translate_screen();
  final auth = FirebaseAuth.instance;
  //select screen
  final screens = [
    translate_screen(),
    quizePage(),
    menuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.blueGrey, // Customize the background color
        activeColor: Colors.white, // Customize the active item color
        color: Colors.white, // Customize the inactive item color
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.translate, title: 'Home'),
          TabItem(icon: Icons.quiz_outlined, title: 'Search'),
          TabItem(icon: Icons.menu, title: 'Menu'),
        ],
        initialActiveIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}

//sign out function
Future<void> logout() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}
