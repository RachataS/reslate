import 'package:flutter/material.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/game_options.dart';
import 'package:reslate/screens/review/matchCard/utils/constants.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.blue[600]!,
              Colors.blue[300]!,
              Colors.blue[100]!,
              // Colors.blue[50]!,
            ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                gameTitle,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              GameOptions(),
            ],
          ),
        ),
      ),
    );
  }
}
