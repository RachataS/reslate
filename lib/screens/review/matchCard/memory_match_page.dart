import 'package:flutter/material.dart';
import 'package:reslate/screens/review/matchCard/widgets/game_board_mobile.dart';

class MemoryMatchPage extends StatelessWidget {
  const MemoryMatchPage({
    required this.gameLevel,
    super.key,
  });

  final int gameLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: LayoutBuilder(
            builder: ((context, constraints) {
              return GameBoardMobile(
                gameLevel: gameLevel,
              );
            }),
          ),
        ),
      ),
    );
  }
}
