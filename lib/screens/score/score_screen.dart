import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice.dart';
import '/controllers/question_controller.dart';

class ScoreScreen extends StatelessWidget {
  var docID;
  final bool savedWordsData;
  late int? numberOfQuestion;
  firebaseDoc firebasedoc = firebaseDoc();

  ScoreScreen({required this.savedWordsData, this.numberOfQuestion});

  @override
  Widget build(BuildContext context) {
    QuestionController _qnController = Get.put(QuestionController());
    return WillPopScope(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.blue[500]!,
                Colors.blue[400]!,
                Colors.blue[300]!,
              ]),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // SvgPicture.asset("assets/icons/bg.svg", fit: BoxFit.fill),
                Column(
                  children: [
                    Spacer(flex: 3),
                    Text(
                      "Score",
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    Text(
                      "${_qnController.correctAnswer}/${_qnController.questions.length}",
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          ?.copyWith(color: Colors.white),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[400],
                                  fixedSize: const Size(300, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              onPressed: () {
                                _qnController.correctAnswer = 0;
                                _qnController.resetQuiz();
                                _qnController.stopTimer();
                                Get.to(bottombar(),
                                    transition: Transition.topLevel);
                              },
                              child: Text("Return")),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[400],
                                  fixedSize: const Size(300, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              onPressed: () async {
                                _qnController.correctAnswer = 0;
                                docID = await firebasedoc.getDocumentId();
                                await firebasedoc.getSavedWords(
                                    numberOfQuestion, savedWordsData, docID);
                                Get.to(
                                    multipleChoice(
                                      savedWordsData: savedWordsData,
                                      docID: docID,
                                      numberOfQuestion: numberOfQuestion,
                                    ),
                                    transition: Transition.topLevel);
                              },
                              child: Text("Play again")),
                        ),
                      ],
                    ),
                    Spacer(flex: 3),
                  ],
                )
              ],
            ),
          ),
        ),
        onWillPop: () async => false);
  }
}
