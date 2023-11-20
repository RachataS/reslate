import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice/components/progress_bar.dart';
import 'package:reslate/screens/review/multipleChoice/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reslate/models/game.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/memory_card.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/restart_game.dart';
import 'dart:math' as math;

class GameBoardMobile extends StatefulWidget {
  const GameBoardMobile({
    required this.gameLevel,
    Key? key,
  }) : super(key: key);

  final int gameLevel;

  @override
  State<GameBoardMobile> createState() => _GameBoardMobileState();
}

class _GameBoardMobileState extends State<GameBoardMobile> {
  late Timer timer;
  late Game game;
  late Duration duration;
  int bestTime = 0;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  Future<void> initializeGame() async {
    game = Game(widget.gameLevel);
    duration = const Duration();
    await game.getWordsList();
    startTimer();
    getBestTime();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    super.dispose();
  }

  void getBestTime() async {
    SharedPreferences gameSP = await SharedPreferences.getInstance();
    if (gameSP.getInt('${widget.gameLevel.toString()}BestTime') != null) {
      bestTime = gameSP.getInt('${widget.gameLevel.toString()}BestTime')!;
    }
    setState(() {});
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) {
        // Check if the widget is still in the tree before updating the state
        return;
      }

      setState(() {
        final seconds = duration.inSeconds + 1;
        duration = Duration(seconds: seconds);
      });

      if (game.isGameOver) {
        timer.cancel();
        SharedPreferences gameSP = await SharedPreferences.getInstance();
        if (gameSP.getInt('${widget.gameLevel.toString()}BestTime') == null ||
            gameSP.getInt('${widget.gameLevel.toString()}BestTime')! >
                duration.inSeconds) {
          gameSP.setInt(
              '${widget.gameLevel.toString()}BestTime', duration.inSeconds);
          setState(() {
            showConfetti = true;
            bestTime = duration.inSeconds;
          });
        }
      }
    });
  }

  pauseTimer() {
    timer.cancel();
  }

  void _resetGame() {
    game.resetGame();
    setState(() {
      timer.cancel();
      duration = const Duration();
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RestartGame(
                    isGameOver: game.isGameOver,
                    pauseGame: () => pauseTimer(),
                    restartGame: () => _resetGame(),
                    continueGame: () => startTimer(),
                    color: Colors.amberAccent[700]!,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.all(20),
                    color: Colors.amber[200]!,
                    child: SizedBox(
                      width: 100,
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[800]!,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${game.score}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    margin: const EdgeInsets.all(10),
                    color: (game.matching <= 8)
                        ? Colors.red[200]!
                        : Colors.green[200]!,
                    child: TextButton(
                      onPressed: () {},
                      child: SizedBox(
                        width: 100,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/card.png',
                                width: 26, height: 26),
                            SizedBox(width: 10),
                            Text(
                              '${game.matching}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(15),
                  //   ),
                  //   margin: const EdgeInsets.all(20),
                  //   color: (game.matching <= 8)
                  //       ? Colors.red[200]!
                  //       : Colors.green[200]!, // Conditional color assignment
                  //   child: SizedBox(
                  //     width: 90,
                  //     height: 50,
                  //     child: Center(
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Image.asset('assets/icons/card.png',
                  //               width: 26, height: 26),
                  //           SizedBox(width: 10),
                  //           Text(
                  //             '${game.matching}',
                  //             style: TextStyle(
                  //                 fontSize: 18, fontWeight: FontWeight.bold),
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: game.gridSize,
                  childAspectRatio: aspectRatio * 1.5,
                  children: List.generate(game.cards.length, (index) {
                    return MemoryCard(
                      index: index,
                      card: game.cards[index],
                      onCardPressed: (int index) {
                        game.onCardPressed(index, context);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
