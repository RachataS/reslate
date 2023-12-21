import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reslate/controllers/getDocument.dart';

import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice/multipleChoice.dart';

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
  int? aids;

  @override
  void initState() {
    super.initState();
    _qnController = Get.put(QuestionController());
    fetchTopScore();
    _updateButtonText();
    updateAids();
  }

  Future<void> updateAids() async {
    print(_qnController.correctAnswer);
    if (_qnController.correctAnswer != 0 &&
        _qnController.correctAnswer % 10 == 0) {
      final collectionReference =
          FirebaseFirestore.instance.collection('Profile').doc(widget.docID);

      // Fetch the current 'aids' value
      DocumentSnapshot<Map<String, dynamic>> userDocument =
          await collectionReference.get();
      int currentAids = userDocument.data()?['aids'] ?? 0;
      int level = userDocument.data()?['archiveLevel'] ?? 0;

      // Check if 'aids' is less than 3 before updating
      if (currentAids < 3 && level <= 2) {
        await collectionReference.update({
          'aids': FieldValue.increment(1),
        });
      }
    }
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
        aids = userDocument.data()?['aids'] ?? 0;
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: (_qnController.correctAnswer < maxQuestion)
                      ? [Colors.red[600]!, Colors.red[300]!, Colors.red[100]!]
                      : [
                          Colors.blue[600]!,
                          Colors.blue[300]!,
                          Colors.blue[100]!,
                        ],
                ),
              ),
              child: Center(
                child: Card(
                  // color: (_qnController.correctAnswer < maxQuestion)
                  //     ? Colors.red[200]
                  //     : Colors.blue[200]!,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.1,
                    vertical: constraints.maxHeight * 0.25,
                  ),
                  child: Column(
                    children: [
                      Spacer(flex: 3),
                      Text(
                        "Top Score",
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.08,
                          color: (_qnController.correctAnswer < maxQuestion)
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      Text(
                        "$topScore",
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                              color: (_qnController.correctAnswer < maxQuestion)
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                      ),
                      Spacer(),
                      Text(
                        "Score",
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.06,
                          color: (_qnController.correctAnswer < maxQuestion)
                              ? Colors.red
                              : Colors.blue,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      Text(
                        "${_qnController.correctAnswer}/$maxQuestion",
                        style: Theme.of(context).textTheme.headline4?.copyWith(
                              color: (_qnController.correctAnswer < maxQuestion)
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth * 0.35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (_qnController.correctAnswer < maxQuestion)
                                        ? Colors.red[400]!
                                        : Colors.blue[400]!,
                                fixedSize: Size(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight * 0.06,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
                                _qnController.correctAnswer = 0;
                                _qnController.resetQuiz();
                                _qnController.stopEverything();

                                Get.to(bottombar(),
                                    transition: Transition.topLevel);
                              },
                              child: Text(
                                "Exit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: constraints.maxWidth * 0.05),
                          SizedBox(
                            width: constraints.maxWidth * 0.35,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    (_qnController.correctAnswer < maxQuestion)
                                        ? Colors.red[400]!
                                        : Colors.blue[400]!,
                                fixedSize: Size(
                                  constraints.maxWidth * 0.7,
                                  constraints.maxHeight * 0.06,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () async {
                                if (widget.numberOfQuestion! >
                                    _qnController.correctAnswer) {
                                  _qnController.correctAnswer = 0;
                                  widget.docID =
                                      await firebasedoc.getDocumentId();
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
                                        numberOfQuestion:
                                            widget.numberOfQuestion,
                                        aids: aids,
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
                                  widget.docID =
                                      await firebasedoc.getDocumentId();
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
                                        numberOfQuestion:
                                            widget.numberOfQuestion! * 2,
                                        aids: aids,
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
                              child: Text(
                                buttonText,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(flex: 3),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
