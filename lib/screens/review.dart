import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/review/multipleChoice/multipleChoice.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/game_options.dart';

class reviewPage extends StatefulWidget {
  final String? docID;

  reviewPage({required this.docID});

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  firebaseDoc firebasedoc = firebaseDoc();
  var numberOfQuestion = 10;

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
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: [savedWordsMode(), WroongAnswerMode()],
        ),
      ),
    );
  }

  Scaffold savedWordsMode() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
              child: Text(
                "Saved Words",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
                child: Column(
                  children: [
                    Text(
                      'Multiple Choice',
                      style: TextStyle(
                        color: Colors.blue[400]!,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 10;
                              setState(() {});
                            },
                            child: Text(
                              '10',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 10
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 10
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 20;
                              setState(() {});
                            },
                            child: Text(
                              '20',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 20
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 20
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 40;
                              setState(() {});
                            },
                            child: Text(
                              '40',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 40
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 40
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 60;
                              setState(() {});
                            },
                            child: Text(
                              '60',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 60
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 60
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            SystemSound.play(SystemSoundType.click);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            int savedWords = await firebasedoc.getSavedWords(
                                numberOfQuestion, true, widget.docID);

                            Navigator.of(context, rootNavigator: true).pop();

                            if (numberOfQuestion <= savedWords) {
                              Get.to(
                                  multipleChoice(
                                    docID: widget.docID,
                                    savedWordsData: true,
                                    numberOfQuestion: numberOfQuestion,
                                  ),
                                  transition: Transition.topLevel);
                            }
                          },
                          child: Text("Let’s play"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
                child: Column(
                  children: [
                    Text(
                      'Match Card',
                      style: TextStyle(
                        color: Colors.blue[400]!,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: GameOptions(
                          docID: widget.docID,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Note : This mode takes the user's recorded words and turns them into questions.",
                style: TextStyle(color: Colors.blue[600]!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.blue[600]!,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.blue[300]!,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold WroongAnswerMode() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
              child: Text(
                "Wrong Answer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
                child: Column(
                  children: [
                    Text(
                      'Multiple Choice',
                      style: TextStyle(
                        color: Colors.blue[400]!,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 10;
                              setState(() {});
                            },
                            child: Text(
                              '10',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 10
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 10
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 20;
                              setState(() {});
                            },
                            child: Text(
                              '20',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 20
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 20
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 40;
                              setState(() {});
                            },
                            child: Text(
                              '40',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 40
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 40
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 60;
                              setState(() {});
                            },
                            child: Text(
                              '60',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: numberOfQuestion == 60
                                      ? Colors.blue
                                      : Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: numberOfQuestion == 60
                                  ? Colors.white
                                  : Colors.blue[400],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            SystemSound.play(SystemSoundType.click);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            int savedWords = await firebasedoc.getSavedWords(
                                numberOfQuestion, false, widget.docID);

                            Navigator.of(context, rootNavigator: true).pop();

                            if (numberOfQuestion <= savedWords) {
                              Get.to(
                                  multipleChoice(
                                    docID: widget.docID,
                                    savedWordsData: false,
                                    numberOfQuestion: numberOfQuestion,
                                  ),
                                  transition: Transition.topLevel);
                            }
                          },
                          child: Text("Let’s play"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
                child: Column(
                  children: [
                    Text(
                      'Match Card',
                      style: TextStyle(
                        color: Colors.blue[400]!,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: GameOptions(
                          docID: widget.docID,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Note : This mode takes the words that the user answered incorrectly and turns them into questions.",
                style: TextStyle(color: Colors.blue[600]!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.blue[300]!,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.blue[600]!,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Scaffold oldStyle() {
  //   return Scaffold(
  //     backgroundColor: Colors.transparent,
  //     body:
  //         // Container(
  //         //   width: double.infinity,
  //         //   decoration: BoxDecoration(
  //         //     gradient: LinearGradient(begin: Alignment.topCenter, colors: [
  //         //       Colors.blue[600]!,
  //         //       Colors.blue[300]!,
  //         //       Colors.blue[100]!,
  //         //       // Colors.blue[50]!,
  //         //     ]),
  //         //   ),
  //         //   child:
  //         Center(
  //       child: Column(
  //         // mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
  //             child: Text(
  //               "Select Mode",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //           Card(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15)),
  //             margin: const EdgeInsets.all(20),
  //             child: Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
  //               child: Column(
  //                 children: [
  //                   Text(
  //                     'Multiple Choice',
  //                     style: TextStyle(
  //                       color: Colors.blue[400]!,
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.only(top: 10),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             numberOfQuestion = 10;
  //                             setState(() {});
  //                           },
  //                           child: Text(
  //                             '10',
  //                             style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: numberOfQuestion == 10
  //                                     ? Colors.blue
  //                                     : Colors.white),
  //                           ),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: numberOfQuestion == 10
  //                                 ? Colors.white
  //                                 : Colors.blue[400],
  //                             shape: CircleBorder(),
  //                             padding: EdgeInsets.all(15),
  //                           ),
  //                         ),
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             numberOfQuestion = 20;
  //                             setState(() {});
  //                           },
  //                           child: Text(
  //                             '20',
  //                             style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: numberOfQuestion == 20
  //                                     ? Colors.blue
  //                                     : Colors.white),
  //                           ),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: numberOfQuestion == 20
  //                                 ? Colors.white
  //                                 : Colors.blue[400],
  //                             shape: CircleBorder(),
  //                             padding: EdgeInsets.all(15),
  //                           ),
  //                         ),
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             numberOfQuestion = 40;
  //                             setState(() {});
  //                           },
  //                           child: Text(
  //                             '40',
  //                             style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: numberOfQuestion == 40
  //                                     ? Colors.blue
  //                                     : Colors.white),
  //                           ),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: numberOfQuestion == 40
  //                                 ? Colors.white
  //                                 : Colors.blue[400],
  //                             shape: CircleBorder(),
  //                             padding: EdgeInsets.all(15),
  //                           ),
  //                         ),
  //                         ElevatedButton(
  //                           onPressed: () {
  //                             numberOfQuestion = 60;
  //                             setState(() {});
  //                           },
  //                           child: Text(
  //                             '60',
  //                             style: TextStyle(
  //                                 fontSize: 16,
  //                                 color: numberOfQuestion == 60
  //                                     ? Colors.blue
  //                                     : Colors.white),
  //                           ),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: numberOfQuestion == 60
  //                                 ? Colors.white
  //                                 : Colors.blue[400],
  //                             shape: CircleBorder(),
  //                             padding: EdgeInsets.all(15),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(20),
  //                     child: SizedBox(
  //                       width: 250,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           SystemSound.play(SystemSoundType.click);

  //                           showDialog(
  //                             context: context,
  //                             barrierDismissible: false,
  //                             builder: (BuildContext context) {
  //                               return Center(
  //                                 child: CircularProgressIndicator(),
  //                               );
  //                             },
  //                           );

  //                           int savedWords = await firebasedoc.getSavedWords(
  //                               numberOfQuestion, true, widget.docID);

  //                           Navigator.of(context, rootNavigator: true).pop();

  //                           if (numberOfQuestion <= savedWords) {
  //                             Get.to(
  //                                 multipleChoice(
  //                                   docID: widget.docID,
  //                                   savedWordsData: true,
  //                                   numberOfQuestion: numberOfQuestion,
  //                                 ),
  //                                 transition: Transition.topLevel);
  //                           }
  //                         },
  //                         child: Text("Saved words"),
  //                         style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue[400],
  //                             fixedSize: const Size(300, 50),
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(50))),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(0),
  //                     child: SizedBox(
  //                       width: 250,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           SystemSound.play(SystemSoundType.click);

  //                           showDialog(
  //                             context: context,
  //                             barrierDismissible: false,
  //                             builder: (BuildContext context) {
  //                               return Center(
  //                                 child: CircularProgressIndicator(),
  //                               );
  //                             },
  //                           );

  //                           int savedWords = await firebasedoc.getSavedWords(
  //                               numberOfQuestion, false, widget.docID);

  //                           Navigator.of(context, rootNavigator: true).pop();

  //                           if (numberOfQuestion <= savedWords) {
  //                             Get.to(
  //                                 multipleChoice(
  //                                   docID: widget.docID,
  //                                   savedWordsData: false,
  //                                   numberOfQuestion: numberOfQuestion,
  //                                 ),
  //                                 transition: Transition.topLevel);
  //                           }
  //                         },
  //                         child: Text("Wrong answer"),
  //                         style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue[400],
  //                             fixedSize: const Size(300, 50),
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(50))),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Card(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(15)),
  //             margin: const EdgeInsets.all(20),
  //             child: Padding(
  //               padding: const EdgeInsets.fromLTRB(20, 40, 10, 40),
  //               child: Column(
  //                 children: [
  //                   Text(
  //                     'Match Card',
  //                     style: TextStyle(
  //                       color: Colors.blue[400]!,
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(20),
  //                     child: SizedBox(
  //                       width: 250,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           SystemSound.play(SystemSoundType.click);

  //                           //match card random method
  //                           Navigator.push(context,
  //                               MaterialPageRoute(builder: (context) {
  //                             return matchCard();
  //                           }));
  //                         },
  //                         child: Text("Saved words"),
  //                         style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue[400],
  //                             fixedSize: const Size(300, 50),
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(50))),
  //                       ),
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.all(0),
  //                     child: SizedBox(
  //                       width: 250,
  //                       child: ElevatedButton(
  //                         onPressed: () async {
  //                           SystemSound.play(SystemSoundType.click);

  //                           //match card random method
  //                           Navigator.push(context,
  //                               MaterialPageRoute(builder: (context) {
  //                             return matchCard();
  //                           }));
  //                         },
  //                         child: Text("Wrong answer"),
  //                         style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.blue[400],
  //                             fixedSize: const Size(300, 50),
  //                             shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(50))),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //     // ),
  //   );
  // }
}
