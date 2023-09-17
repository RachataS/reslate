import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController(index: 0);

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
        reviewPage(
          docID: firebaseDocument.id,
        ),
        menuPage(profile: profile),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : screens.isNotEmpty
                ? Scaffold(
                    body: screens[currentIndex],
                  )
                : PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                        screens.length, (index) => screens[index]),
                  ),
        extendBody: true,
        bottomNavigationBar: isLoading || screens.isEmpty
            ? null
            : AnimatedNotchBottomBar(
                notchBottomBarController: _controller,
                color: Colors.blue[400]!,
                showLabel: true,
                itemLabelStyle: TextStyle(color: Colors.white, fontSize: 13),
                notchColor: Colors.white,
                removeMargins: false,
                bottomBarWidth: 400,
                durationInMilliSeconds: 100,
                bottomBarItems: [
                  const BottomBarItem(
                    inActiveItem: Icon(
                      Icons.g_translate_outlined,
                      color: Colors.white,
                    ),
                    activeItem: Icon(
                      Icons.g_translate_outlined,
                      color: Colors.blue,
                    ),
                    itemLabel: 'Translate',
                  ),
                  const BottomBarItem(
                    inActiveItem: Icon(
                      Icons.api_rounded,
                      color: Colors.white,
                    ),
                    activeItem: Icon(
                      Icons.api_rounded,
                      color: Colors.blue,
                    ),
                    itemLabel: 'Review',
                  ),
                  const BottomBarItem(
                    inActiveItem: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    activeItem: Icon(
                      Icons.menu,
                      color: Colors.blue,
                    ),
                    itemLabel: 'Menu',
                  ),
                ],
                onTap: (index) {
                  setState(() => currentIndex = index);
                  _controller.index = index;
                },
              ),
      ),
    );
  }
}
