import 'package:flutter/material.dart';

class matchCard extends StatefulWidget {
  const matchCard({super.key});

  @override
  State<matchCard> createState() => _matchCardState();
}

class _matchCardState extends State<matchCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[600]!,
            Colors.blue[300]!,
            Colors.blue[100]!,
            // Colors.blue[50]!,
          ]),
        ),
        child: Center(
          child: Text("matchCard"),
        ),
      ),
    );
  }
}
