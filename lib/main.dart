import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/bottomBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: FirebaseOptions(
      //     apiKey: 'AIzaSyCCOBglvd14ORH2RrCjO1nosCPkE7yIYTE',
      //     appId: '1:400328617499:web:7a1fcb9943002caaaf12be',
      //     messagingSenderId: '400328617499',
      //     projectId: 'reslate-7d93b')
      );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: Colors.blue,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: bottombar(),
    );
  }
}
