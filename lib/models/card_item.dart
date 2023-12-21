import 'package:flutter/material.dart';

enum CardState { hidden, visible, guessed }

class CardItem {
  CardItem(
      {required this.id,
      required this.question,
      required this.color,
      this.state = CardState.hidden,
      this.matched = false,
      this.check});

  final int id;

  final String question;
  final Color color;
  CardState state;
  bool matched;
  int? check;
}
