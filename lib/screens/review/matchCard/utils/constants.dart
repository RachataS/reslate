import 'package:flutter/material.dart';

const Color continueButtonColor = Color.fromRGBO(235, 32, 93, 1);
const Color restartButtonColor = Color.fromRGBO(243, 181, 45, 1);
const Color quitButtonColor = Color.fromRGBO(39, 162, 149, 1);

const List<Map<String, dynamic>> gameLevels = [
  {'title': 'Level 1 (4 x 4)', 'level': 4, 'color': Colors.cyanAccent},
  {'title': 'Level 2 (6 x 6)', 'level': 6, 'color': Colors.blueAccent},
  {'title': 'Level 3 (8 x 8)', 'level': 8, 'color': Colors.deepPurpleAccent},
];

const String gameTitle = 'Match Card';
