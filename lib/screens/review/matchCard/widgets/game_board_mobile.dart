import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice/components/progress_bar.dart';
import 'package:reslate/screens/review/multipleChoice/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reslate/controllers/game.dart';
import 'package:reslate/screens/review/matchCard/widgets/memory_card.dart';
import 'package:reslate/screens/review/matchCard/widgets/restart_game.dart';
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
  firebaseDoc firebasedoc = firebaseDoc();
  var docID, aids;

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
    docID = await firebasedoc.getDocumentId();

    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Profile').doc(docID).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      aids = data['aids'];
    } else {
      print('Document does not exist');
    }
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
                  Expanded(
                    child: RestartGame(
                      isGameOver: game.isGameOver,
                      pauseGame: () => pauseTimer(),
                      restartGame: () => _resetGame(),
                      continueGame: () => startTimer(),
                      color: Colors.amberAccent[700]!,
                    ),
                  ),
                  Flexible(
                    child: Card(
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
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      margin: const EdgeInsets.all(10),
                      color: (game.matching <= 8)
                          ? Colors.red[200]!
                          : Colors.green[200]!,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.blue[100]!,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      40), // Adjust the radius as needed
                                ),
                                title: Text(
                                  "Add matching time\n${aids}/3",
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "Are you sure you want to add matching 10 time",
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (aids > 0) {
                                            game.addMatchingTime();

                                            await FirebaseFirestore.instance
                                                .collection('Profile')
                                                .doc(docID)
                                                .update({'aids': aids - 1});

                                            setState(() {
                                              aids = aids - 1;
                                            });
                                          }
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Use",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          );
                        },
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
                  ),
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
