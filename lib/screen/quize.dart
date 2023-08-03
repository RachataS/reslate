import 'package:flutter/material.dart';

class quizePage extends StatefulWidget {
  const quizePage({super.key});

  @override
  State<quizePage> createState() => _quizePageState();
}

class _quizePageState extends State<quizePage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('quize'));
  }
}
