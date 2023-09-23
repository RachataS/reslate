import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reslate/screen/authentication/login.dart';
import 'package:reslate/screen/bottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: bottombar(),
    );
  }
}
