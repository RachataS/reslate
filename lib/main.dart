import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/authentication/login.dart';
import 'package:reslate/screens/bottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: bottombar(),
    );
  }
}
