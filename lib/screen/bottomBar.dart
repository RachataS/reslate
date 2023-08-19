import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reslate/screen/authentication/login.dart';
import 'package:reslate/screen/menu.dart';
import 'package:reslate/screen/review.dart';
import 'package:reslate/screen/Translate.dart';

import '../model/getDocument.dart';
import '../model/profile.dart';

class bottombar extends StatefulWidget {
  const bottombar({Key? key}) : super(key: key);

  @override
  State<bottombar> createState() => _bottombarState();
}

class _bottombarState extends State<bottombar> {
  firebaseDoc firebasedoc = firebaseDoc();
  late DocumentReference firebaseDocument;

  int currentIndex = 0;
  Profile profile = Profile();
  late List<Widget> screens = [];
  bool isLoading = true;
  var docID;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      docID = await firebasedoc.getDocumentId();
      if (docID == null) {
        firebaseDocument =
            await FirebaseFirestore.instance.collection('Profile').doc();
      } else {
        firebaseDocument = await FirebaseFirestore.instance
            .collection('Profile')
            .doc('$docID');
      }
      await getDocumentData();
    } catch (e) {
      print('Error initializing page: $e');
    }
  }

  Future<void> getDocumentData() async {
    DocumentSnapshot documentSnapshot = await firebaseDocument.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        profile.data = data;
        print(profile.data);
      } else {
        print('Data is null or not a Map<String, dynamic>');
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return loginPage();
      }));
    }
    setState(() {
      screens = [
        translate_screen(
            docID: firebaseDocument.id,
            sendData: (data) {
              setState(() {
                profile.data = data;
              });
            }),
        reviewPage(),
        menuPage(profile: profile),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : screens.isNotEmpty
              ? screens[currentIndex]
              : Container(),
      bottomNavigationBar: isLoading || screens.isEmpty
          ? null
          : ConvexAppBar(
              backgroundColor: Colors.blueGrey,
              activeColor: Colors.white,
              color: Colors.white,
              style: TabStyle.react,
              top: -20,
              curveSize: 100,
              items: [
                TabItem(icon: Icons.g_translate_outlined, title: 'Translate'),
                TabItem(icon: Icons.rate_review_sharp, title: 'Review'),
                TabItem(icon: Icons.menu, title: 'Menu'),
              ],
              initialActiveIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
            ),
    );
  }
}
