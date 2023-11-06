import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/screens/review/components/body.dart';

class multipleChoice extends StatefulWidget {
  final String? docID;
  final bool? savedWordsData;
  final int? numberOfQuestion;
  multipleChoice(
      {required this.docID,
      required this.savedWordsData,
      required this.numberOfQuestion});

  @override
  State<multipleChoice> createState() => _multipleChoiceState();
}

class _multipleChoiceState extends State<multipleChoice> {
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("Profile");

  @override
  void initState() {
    super.initState();
    getQuestion();
    print("from multi = ${widget.savedWordsData}");
    getSavedWords(widget.numberOfQuestion);
  }

  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());

    _controller.updateSavedWordsData(widget.savedWordsData);

    return WillPopScope(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: _controller.nextQuestion,
                    child: Text(
                      "Exit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
              ],
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: getQuestion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Text('Error loading question');
              } else {
                List<Map<String, dynamic>> firestoreData = snapshot.data!;
                _controller.setData(firestoreData);
                return Body();
              }
            },
          ),
        ),
        onWillPop: () async => false);
  }

  Future<List<Map<String, dynamic>>> getQuestion() async {
    List<Map<String, dynamic>> firestoreData = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await userCollection.doc(widget.docID).collection("savedWords").get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Map<String, dynamic> data = document.data();
        firestoreData.add(data);
      }

      // Determine whether to sort by answerCorrect or answerWrong
      String sortByField =
          widget.savedWordsData ?? false ? "answerCorrect" : "answerWrong";

      // Sort the data based on the chosen field
      firestoreData.sort((a, b) => a[sortByField].compareTo(b[sortByField]));

      // Determine whether to show questions in ascending or descending order
      bool ascendingOrder = (widget.savedWordsData ?? false)
          ? (firestoreData.last[sortByField] <= 0)
          : (firestoreData.first[sortByField] <= 0);

      // If ascending order, reverse the list
      if (ascendingOrder) {
        firestoreData = List.from(firestoreData.reversed);
      }

      return firestoreData;
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Return an empty list on error
    }
  }

  Future<void> getSavedWords(numberOfQuestion) async {
    List<Map<String, dynamic>> savedWords = [];
    print(numberOfQuestion);

    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);
    QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await userDocumentRef.collection("savedWords").get();

    savedWordsQuerySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();
      savedWords.add(data);
    });

    if (savedWords.isNotEmpty) {
      var wordLength;
      await userDocumentRef
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> document) {
        if (document.exists) {
          Map<String, dynamic> data = document.data()!;
          wordLength = data["wordLength"];
        }
      }).catchError((error) {
        print("Error getting document: $error");
      });

      Random random = Random();

      for (int a = 0; a < wordLength; a++) {
        Map<String, dynamic> randomWord = savedWords[a];
        String thaiKey = randomWord['thai'];
        String engKey = randomWord['question'];
        String thaiKey1, thaiKey2, thaiKey3;
        List<dynamic> reviewList = randomWord['options'];

        try {
          if (reviewList.length < 5) {
            // Initialize a list to store the random indices
            List<int> randomIndices = [];

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
          Fluttertoast.showToast(msg: '${e}', gravity: ToastGravity.TOP);
        }
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
      DocumentReference<Map<String, dynamic>> newDocumentRef = userCollection
          .doc(widget.docID)
          .collection("savedWords")
          .doc(question);

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
      print(e);
    }
  }
}
