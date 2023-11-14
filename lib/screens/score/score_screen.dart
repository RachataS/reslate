import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice.dart';
import '/controllers/question_controller.dart';

class ScoreScreen extends StatefulWidget {
  final bool savedWordsData;
  final int? numberOfQuestion;
  var docID;

  ScoreScreen({
    Key? key,
    required this.savedWordsData,
    this.numberOfQuestion,
    required this.docID,
  }) : super(key: key);

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  firebaseDoc firebasedoc = firebaseDoc();
  late int topScore = 0;
  late String buttonText;
  late QuestionController _qnController;
  var maxQuestion;

  @override
  void initState() {
    super.initState();
    _qnController = Get.put(QuestionController());
    fetchTopScore();
    _updateButtonText();
  }

  void _updateButtonText() {
    buttonText = (_qnController.correctAnswer >= (widget.numberOfQuestion ?? 0))
        ? "Next Level"
        : "Play again";

    maxQuestion = _qnController.questions.length;
    if (_qnController.correctAnswer > maxQuestion) {
      setState(() {
        maxQuestion += maxQuestion;
      });
    }
  }

  void fetchTopScore() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await FirebaseFirestore.instance
            .collection("Profile")
            .doc(widget.docID)
            .get();

    if (userDocument.exists) {
      setState(() {
        topScore = userDocument.data()?['topScore'] ?? 0;
      });
      if (topScore < _qnController.correctAnswer) {
        setState(() {
          topScore = _qnController.correctAnswer;
        });
        await FirebaseFirestore.instance
            .collection("Profile")
            .doc(widget.docID)
            .update({'topScore': topScore});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestionController _qnController = Get.put(QuestionController());
    return WillPopScope(
      child: Scaffold(
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.red[600]!,
                  Colors.red[300]!,
                  Colors.red[100]!,
                ],
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.fromLTRB(30, 250, 30, 250),
              child: Column(
                children: [
                  Spacer(flex: 3),
                  Text("Top Score",
                      style: TextStyle(fontSize: 40, color: Colors.red)),
                  SizedBox(height: 30),
                  Text(
                    "${topScore}",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        ?.copyWith(color: Colors.red),
                  ),
                  Spacer(),
                  Text(
                    "Score",
                    style: TextStyle(fontSize: 35, color: Colors.red),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "${_qnController.correctAnswer}/${maxQuestion}",
                    style: Theme.of(context)
                        .textTheme
                        .headline4
                        ?.copyWith(color: Colors.red),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            fixedSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            _qnController.correctAnswer = 0;
                            _qnController.resetQuiz();
                            Get.to(bottombar(),
                                transition: Transition.topLevel);
                          },
                          child: Text("Return"),
                        ),
                      ),
                      SizedBox(width: 30),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            fixedSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () async {
                            if (widget.numberOfQuestion! >
                                _qnController.correctAnswer) {
                              _qnController.correctAnswer = 0;
                              widget.docID = await firebasedoc.getDocumentId();
                              var savedWordsLength =
                                  await firebasedoc.getSavedWords(
                                widget.numberOfQuestion,
                                widget.savedWordsData,
                                widget.docID,
                              );

                              if (savedWordsLength >=
                                  (widget.numberOfQuestion ?? 0)) {
                                Get.to(
                                  multipleChoice(
                                    savedWordsData: widget.savedWordsData,
                                    docID: widget.docID,
                                    numberOfQuestion: widget.numberOfQuestion,
                                  ),
                                  transition: Transition.topLevel,
                                );
                              } else {
                                Get.to(
                                  bottombar(),
                                  transition: Transition.topLevel,
                                );
                              }
                            } else {
                              widget.docID = await firebasedoc.getDocumentId();
                              var savedWordsLength =
                                  await firebasedoc.getSavedWords(
                                widget.numberOfQuestion,
                                widget.savedWordsData,
                                widget.docID,
                              );

                              if (savedWordsLength >=
                                  (widget.numberOfQuestion ?? 0)) {
                                Get.to(
                                  multipleChoice(
                                    savedWordsData: widget.savedWordsData,
                                    docID: widget.docID,
                                    numberOfQuestion: widget.numberOfQuestion,
                                  ),
                                  transition: Transition.topLevel,
                                );
                              } else {
                                Get.to(
                                  bottombar(),
                                  transition: Transition.topLevel,
                                );
                              }
                            }
                          },
                          child: Text(buttonText),
                        ),
                      ),
                    ],
                  ),
                  Spacer(flex: 3),
                ],
              ),
            )
            // Stack(
            //   fit: StackFit.expand,
            //   children: [
            //     Column(
            //       children: [
            //         Spacer(flex: 3),
            //         Text("Top Score",
            //             style: TextStyle(fontSize: 40, color: Colors.white)),
            //         SizedBox(height: 30),
            //         Text(
            //           "${topScore}",
            //           style: Theme.of(context)
            //               .textTheme
            //               .headline4
            //               ?.copyWith(color: Colors.white),
            //         ),
            //         SizedBox(
            //           height: 50,
            //         ),
            //         Text(
            //           "Score",
            //           style: TextStyle(fontSize: 35, color: Colors.white),
            //         ),
            //         SizedBox(height: 30),
            //         Text(
            //           "${_qnController.correctAnswer}/${maxQuestion}",
            //           style: Theme.of(context)
            //               .textTheme
            //               .headline4
            //               ?.copyWith(color: Colors.white),
            //         ),
            //         Spacer(),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             SizedBox(
            //               width: 150,
            //               child: ElevatedButton(
            //                 style: ElevatedButton.styleFrom(
            //                   backgroundColor: Colors.blue[400],
            //                   fixedSize: const Size(300, 50),
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(50),
            //                   ),
            //                 ),
            //                 onPressed: () {
            //                   _qnController.correctAnswer = 0;
            //                   _qnController.resetQuiz();
            //                   Get.to(bottombar(),
            //                       transition: Transition.topLevel);
            //                 },
            //                 child: Text("Return"),
            //               ),
            //             ),
            //             SizedBox(width: 30),
            //             SizedBox(
            //               width: 150,
            //               child: ElevatedButton(
            //                 style: ElevatedButton.styleFrom(
            //                   backgroundColor: Colors.blue[400],
            //                   fixedSize: const Size(300, 50),
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(50),
            //                   ),
            //                 ),
            //                 onPressed: () async {
            //                   if (widget.numberOfQuestion! >
            //                       _qnController.correctAnswer) {
            //                     _qnController.correctAnswer = 0;
            //                     widget.docID = await firebasedoc.getDocumentId();
            //                     var savedWordsLength =
            //                         await firebasedoc.getSavedWords(
            //                       widget.numberOfQuestion,
            //                       widget.savedWordsData,
            //                       widget.docID,
            //                     );

            //                     if (savedWordsLength >=
            //                         (widget.numberOfQuestion ?? 0)) {
            //                       Get.to(
            //                         multipleChoice(
            //                           savedWordsData: widget.savedWordsData,
            //                           docID: widget.docID,
            //                           numberOfQuestion: widget.numberOfQuestion,
            //                         ),
            //                         transition: Transition.topLevel,
            //                       );
            //                     } else {
            //                       Get.to(
            //                         bottombar(),
            //                         transition: Transition.topLevel,
            //                       );
            //                     }
            //                   } else {
            //                     widget.docID = await firebasedoc.getDocumentId();
            //                     var savedWordsLength =
            //                         await firebasedoc.getSavedWords(
            //                       widget.numberOfQuestion,
            //                       widget.savedWordsData,
            //                       widget.docID,
            //                     );

            //                     if (savedWordsLength >=
            //                         (widget.numberOfQuestion ?? 0)) {
            //                       Get.to(
            //                         multipleChoice(
            //                           savedWordsData: widget.savedWordsData,
            //                           docID: widget.docID,
            //                           numberOfQuestion: widget.numberOfQuestion,
            //                         ),
            //                         transition: Transition.topLevel,
            //                       );
            //                     } else {
            //                       Get.to(
            //                         bottombar(),
            //                         transition: Transition.topLevel,
            //                       );
            //                     }
            //                   }
            //                 },
            //                 child: Text(buttonText),
            //               ),
            //             ),
            //           ],
            //         ),
            //         Spacer(flex: 3),
            //       ],
            //     )
            //   ],
            // ),
            ),
      ),
      onWillPop: () async => false,
    );
  }
}
