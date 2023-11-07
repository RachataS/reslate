import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';
import 'package:reslate/screens/review/multipleChoice.dart';
import '/controllers/question_controller.dart';

class ScoreScreen extends StatelessWidget {
  var docID;
  final bool savedWordsData;
  late int? numberOfQuestion;

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
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          onPressed: () async {
                            _qnController.correctAnswer = 0;
                            firebaseDoc firebasedoc = firebaseDoc();
                            docID = await firebasedoc.getDocumentId();
                            getSavedWords(numberOfQuestion, savedWordsData);
                            Get.to(multipleChoice(
                              savedWordsData: savedWordsData,
                              docID: docID,
                            ));
                          },
                          child: Text("Play again")),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 300,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[400],
                                fixedSize: const Size(300, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50))),
                            onPressed: () {
                              _qnController.correctAnswer = 0;
                              Get.to(bottombar());
                            },
                            child: Text("Return")),
                      ),
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

  Future<void> getSavedWords(var numberOfQuestion, bool savedWordsData) async {
    print(docID);
    List<Map<String, dynamic>> savedWords = [];

    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(docID);
    QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await userDocumentRef.collection("savedWords").get();

    savedWordsQuerySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();
      savedWords.add(data);
    });

    if (savedWords.isNotEmpty) {
      // Sort the savedWords list based on the chosen field and order
      String sortByField = savedWordsData ? "answerCorrect" : "answerWrong";
      savedWords.sort((a, b) => a[sortByField].compareTo(b[sortByField]));

      if (!savedWordsData) {
        savedWords = savedWords.reversed.toList();
      }

      Random random = Random();

      if (numberOfQuestion <= savedWords.length) {
        List<int> randomIndices = [];

        for (int a = 0; a < numberOfQuestion && a < savedWords.length; a++) {
          Map<String, dynamic> randomWord = savedWords[a];
          String thaiKey = randomWord['thai'];
          String engKey = randomWord['question'];
          String thaiKey1, thaiKey2, thaiKey3;
          List<dynamic> reviewList = randomWord['options'];

          try {
            if (reviewList.length < 5) {
              // Update the "beQuestion" field to true for the selected word
              savedWords[a]['beQuestion'] = true;

              while (randomIndices.length < 3) {
                int randomIndex;
                do {
                  randomIndex = random.nextInt(savedWords.length);
                } while (randomIndex == a ||
                    randomIndices.contains(randomIndex)); // Avoid duplicates
                randomIndices.add(randomIndex);
              }

              // Get the Thai keys for the randomly selected incorrect answers
              List randomThaiKeys = randomIndices
                  .map((index) => savedWords[index]['thai'])
                  .toList();

              // Ensure that the correct answer is not in the list of incorrect answers
              randomThaiKeys.remove(thaiKey);

              thaiKey1 = randomThaiKeys[0];
              thaiKey2 = randomThaiKeys[1];
              thaiKey3 = randomThaiKeys[2];
              await saveChoice(engKey, thaiKey, thaiKey1, thaiKey2, thaiKey3);
            }
          } catch (e) {
            print('random choice error ${e}');
          }
          // print('${a} = ${engKey}');
        }

        // Update the Firestore documents to set "beQuestion" to false for the remaining words
        for (int i = numberOfQuestion; i < savedWords.length; i++) {
          savedWords[i]['beQuestion'] = false;
        }

        // Batch Firestore updates for "beQuestion" values
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (Map<String, dynamic> wordData in savedWords) {
          DocumentReference docRef = userDocumentRef
              .collection("savedWords")
              .doc(wordData['question']);
          batch.set(
            docRef,
            {'beQuestion': wordData['beQuestion']},
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      } else {
        Fluttertoast.showToast(
            msg: "คุณมีคำศัพท์ไม่ถึง ${numberOfQuestion} คำ",
            gravity: ToastGravity.TOP);
      }
    } else {
      print('No savedWords available.');
    }
  }

  Future<void> saveChoice(
    question,
    correctAnswer,
    answer1,
    answer2,
    answer3,
  ) async {
    CollectionReference<Map<String, dynamic>> userCollection =
        FirebaseFirestore.instance.collection("Profile");

    try {
      DocumentReference<Map<String, dynamic>> newDocumentRef =
          userCollection.doc(docID).collection("savedWords").doc(question);

      // Create an array of answers with the correct answer included
      List<String> answerArray = [correctAnswer, answer1, answer2, answer3];

      // Shuffle the answerArray to randomize the order
      answerArray.shuffle();

      // Find the index of the correct answer within the shuffled array
      int correctAnswerIndex = answerArray.indexOf(correctAnswer);

      Map<String, dynamic> dataToStore = {
        "options": answerArray,
        "answer_index": correctAnswerIndex,
      };
      await newDocumentRef.set(dataToStore, SetOptions(merge: true));
    } catch (e) {
      print('saveChoice at score error ${e}');
    }
  }
}
