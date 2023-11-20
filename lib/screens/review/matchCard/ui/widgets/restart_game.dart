import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/game_controls_bottomsheet.dart';

class RestartGame extends StatelessWidget {
  const RestartGame({
    required this.isGameOver,
    required this.pauseGame,
    required this.restartGame,
    required this.continueGame,
    this.color = Colors.white,
    super.key,
  });

  final VoidCallback pauseGame;
  final VoidCallback restartGame;
  final VoidCallback continueGame;
  final bool isGameOver;
  final Color color;

  Future<void> showGameControls(BuildContext context) async {
    pauseGame();
    var value = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const GameControlsBottomSheet();
      },
    );

    value ??= false;

    if (value) {
      restartGame();
    } else {
      continueGame();
    }
  }

  void navigateBack(BuildContext context) {
    Get.to(bottombar(), transition: Transition.topLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      margin: const EdgeInsets.all(10),
      color: Colors.blue[300]!,
      child: TextButton(
        onPressed: () =>
            isGameOver ? navigateBack(context) : showGameControls(context),
        child: SizedBox(
          width: 100,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                color: Colors.black,
                size: 22,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'Setting',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
