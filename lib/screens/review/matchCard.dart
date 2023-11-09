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
      body: Center(
        child: Text("matchCard"),
      ),
    );
  }
}
