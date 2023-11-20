import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/game_button.dart';
import 'package:reslate/screens/review/matchCard/utils/constants.dart';

class GameControlsBottomSheet extends StatelessWidget {
  const GameControlsBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Continue the game
      },
      child: Dialog(
        backgroundColor: Colors.blue[100]!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'PAUSE',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              GameButton(
                onPressed: () => Navigator.of(context).pop(false),
                title: 'CONTINUE',
                color: continueButtonColor,
                width: 200,
              ),
              const SizedBox(height: 10),
              GameButton(
                onPressed: () => Navigator.of(context).pop(true),
                title: 'RESTART',
                color: restartButtonColor,
                width: 200,
              ),
              const SizedBox(height: 10),
              GameButton(
                onPressed: () {
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) {
                  //       return const StartUpPage();
                  //     },
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                  Get.to(bottombar(), transition: Transition.topLevel);
                },
                title: 'QUIT',
                color: quitButtonColor,
                width: 200,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
