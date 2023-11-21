import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reslate/screens/authentication/login.dart';
import 'package:reslate/screens/menu.dart';
import 'package:reslate/screens/review/review.dart';
import 'package:reslate/screens/Translate.dart';

import '../controllers/getDocument.dart';
import '../models/profile.dart';

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

  // new bottom bar style
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : screens.isNotEmpty
                ? PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                        screens.length, (index) => screens[index]),
                  )
                : Container(),
        extendBody: true,
        bottomNavigationBar: isLoading || screens.isEmpty
            ? null
            : Theme(
                data: Theme.of(context).copyWith(
                  // Set the elevation to 0 to remove the shadow
                  canvasColor:
                      Colors.transparent, // Set the canvas color to transparent
                ),
                child: BottomNavigationBar(
                  fixedColor: Colors.blue[600]!,
                  backgroundColor: Colors.transparent,
                  elevation: 0, // Set the elevation to 0 to remove the shadow
                  currentIndex: currentIndex,
                  onTap: (index) {
                    setState(() {
                      currentIndex = index;
                      _pageController.jumpToPage(index);
                      // slide
                      // _pageController.animateToPage(index,
                      //     duration: Duration(milliseconds: 250),
                      //     curve: Curves.ease);
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.g_translate_outlined),
                      label: 'Translate',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.quiz_rounded),
                      label: 'Review',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu),
                      label: 'Menu',
                    ),
                  ],
                ),
              ),
      ),
      onWillPop: () async => false,
    );
  }

  // old bottom bar style
  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //       child: GestureDetector(
  //         onTap: () {
  //           FocusScope.of(context).unfocus();
  //         },
  //         child: Scaffold(
  //           resizeToAvoidBottomInset: false,
  //           body: isLoading
  //               ? Center(
  //                   child: CircularProgressIndicator(),
  //                 )
  //               : screens.isNotEmpty
  //                   ? Scaffold(
  //                       body: screens[currentIndex],
  //                     )
  //                   : PageView(
  //                       controller: _pageController,
  //                       physics: const NeverScrollableScrollPhysics(),
  //                       children: List.generate(
  //                           screens.length, (index) => screens[index]),
  //                     ),
  //           extendBody: true,
  //           bottomNavigationBar: isLoading || screens.isEmpty
  //               ? null
  //               : AnimatedNotchBottomBar(
  //                   notchBottomBarController: _controller,
  //                   color: Colors.blue[400]!,
  //                   showLabel: true,
  //                   itemLabelStyle:
  //                       TextStyle(color: Colors.white, fontSize: 13),
  //                   notchColor: Colors.white,
  //                   removeMargins: false,
  //                   bottomBarWidth: 400,
  //                   durationInMilliSeconds: 100,
  //                   bottomBarItems: [
  //                     const BottomBarItem(
  //                       inActiveItem: Icon(
  //                         Icons.g_translate_outlined,
  //                         color: Colors.white,
  //                       ),
  //                       activeItem: Icon(
  //                         Icons.g_translate_outlined,
  //                         color: Colors.blue,
  //                       ),
  //                       itemLabel: 'Translate',
  //                     ),
  //                     const BottomBarItem(
  //                       inActiveItem: Icon(
  //                         Icons.quiz_rounded,
  //                         color: Colors.white,
  //                       ),
  //                       activeItem: Icon(
  //                         Icons.quiz_rounded,
  //                         color: Colors.blue,
  //                       ),
  //                       itemLabel: 'Review',
  //                     ),
  //                     const BottomBarItem(
  //                       inActiveItem: Icon(
  //                         Icons.menu,
  //                         color: Colors.white,
  //                       ),
  //                       activeItem: Icon(
  //                         Icons.menu,
  //                         color: Colors.blue,
  //                       ),
  //                       itemLabel: 'Menu',
  //                     ),
  //                   ],
  //                   onTap: (index) {
  //                     setState(() => currentIndex = index);
  //                     _controller.index = index;
  //                   },
  //                 ),
  //         ),
  //       ),
  //       onWillPop: () async => false);
  // }
}
