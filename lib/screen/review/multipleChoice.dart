import 'package:flutter/material.dart';

class multipleChoice extends StatefulWidget {
  const multipleChoice({super.key});

  @override
  State<multipleChoice> createState() => _multipleChoiceState();
}

class _multipleChoiceState extends State<multipleChoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("multipleChoice"),
      ),
    );
  }
}
