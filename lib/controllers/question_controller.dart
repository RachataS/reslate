import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:reslate/models/getDocument.dart';
import '/models/Questions.dart';
import '../screens/review/multipleChoice/score_screen.dart';

// We use get package for our state management

class QuestionController extends GetxController
    with SingleGetTickerProviderMixin {
  // Lets animated our progress bar

  late AnimationController _animationController;
  late Animation _animation;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  late PageController _pageController;
  PageController get pageController => this._pageController;

  int currentPage = 1;
  late bool savedWordsData;
  late int? numberOfQuestion;

  QuestionController({this.numberOfQuestion}) {
    _pageController = PageController();
  }
  Question question = Question();

  List<Question> _questions = Question.sample_data
      .map(
        (questionData) => Question(
          id: questionData['id'],
          question: questionData['question'],
          options: questionData['options'],
          answer: questionData['answer_index'],
        ),
      )
      .toList();

  List<Question> get questions => this._questions;

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;

  late int _correctAns;
  int get correctAns => this._correctAns;

  late int _selectedAns;
  int get selectedAns => this._selectedAns;

  // for more about obs please check documentation
  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  int correctAnswer = 0;

  String? docID;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s
    _animationController =
        AnimationController(duration: Duration(seconds: 15), vsync: this);
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    getDocId();
    _animationController.reset();
    // start our animation

    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  // ignore: body_might_complete_normally_nullable
  Future<String?> getDocId() async {
    try {
      firebaseDoc firebasedoc = firebaseDoc();
      docID = await firebasedoc.getDocumentId();
    } catch (e) {
      print(e);
    }
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question question, int selectedIndex) async {
    DocumentSnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(docID)
            .collection("savedWords")
            .doc('${_questions[_questionNumber.value - 1].question}')
            .get();
    // because once user press any option then it will run
    _isAnswered = true;
    _correctAns = question.answer;
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns) {
      _numOfCorrectAns++;
      correctAnswer++;
    }
    ;

    // It will stop the counter
    _animationController.stop();
    update();
    if (savedWordsQuerySnapshot.exists) {
      final data = savedWordsQuerySnapshot.data();
      var answerCorrect, answerWrong, correctStrike;

      if (data != null && data.containsKey('answerCorrect')) {
        answerCorrect = data['answerCorrect'];
        answerWrong = data['answerWrong'];
        correctStrike = data['correctStrike'];
      }
      try {
        if (_correctAns == _selectedAns) {
          await updateAnswerCorrectInFirebase(
              answerCorrect, answerWrong, correctStrike);
        } else {
          Future.delayed(const Duration(seconds: 1), () async {
            await updateAnswerWrongInFirebase(
                answerCorrect, answerWrong, correctStrike);
            resetQuiz();
            Get.to(
                () => ScoreScreen(
                      savedWordsData: savedWordsData,
                      numberOfQuestion: numberOfQuestion,
                      docID: docID,
                    ),
                transition: Transition.topLevel);
          });

          return; // Return to prevent further execution
        }
      } catch (e) {
        print(e);
      }
    }
    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(Duration(milliseconds: 500), () {
      nextQuestion();
    });
  }

  Future<void> setData(List<Map<String, dynamic>> data) async {
    // Process and use the data in your controller as needed
    // For example, you can update the questions list here.
    // Be sure to clear any existing data if needed.
    _questions.clear();

    await Future.forEach(data, (questionData) {
      _questions.add(
        Question(
          id: questionData['id'],
          question: questionData['question'],
          options: questionData['options'],
          answer: questionData['answer_index'],
        ),
      );
    });

    update(); // Ensure the UI is updated after setting the data.
  }

  void nextQuestion() async {
    if (_questionNumber.value < _questions.length) {
      if (_isAnswered) {
        _isAnswered = false;
        _pageController.nextPage(
          duration: Duration(milliseconds: 100),
          curve: Curves.ease,
        );
      } else {
        // Future.delayed(const Duration(seconds: 1), () {
        resetQuiz();
        Get.to(
            () => ScoreScreen(
                  savedWordsData: savedWordsData,
                  numberOfQuestion: numberOfQuestion,
                  docID: docID,
                ),
            transition: Transition.topLevel);
        // });
        return;
      }

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once the timer is finished, go to the next question
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      // All questions answered, go to the ScoreScreen

      Future.delayed(const Duration(seconds: 1), () {
        resetQuiz();
        Get.to(
            () => ScoreScreen(
                  savedWordsData: savedWordsData,
                  numberOfQuestion: numberOfQuestion,
                  docID: docID,
                ),
            transition: Transition.topLevel);
      });
    }
  }

  Future<void> updateAnswerCorrectInFirebase(
      int answerCorrectCount, int answerWrongCount, int correctStrike) async {
    final subcollectionReference = FirebaseFirestore.instance
        .collection('Profile')
        .doc(docID)
        .collection("savedWords");

    if (savedWordsData == true) {
      if (correctStrike >= 3) {
        await Get.dialog(
          AlertDialog(
            backgroundColor: Colors.amber[100]!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow[700]!,
                      size: 50,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow[700]!,
                      size: 50,
                    ),
                    Icon(
                      Icons.star,
                      color: Colors.yellow[700]!,
                      size: 50,
                    ),
                  ],
                ),
                Text('You have answered this word correctly 3 times.'),
              ],
            ),
            content: Text('Do you want to delete this word?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      await subcollectionReference
                          .doc(
                              '${_questions[_questionNumber.value - 1].question}')
                          .update({
                        'answerCorrect': answerCorrectCount = 0,
                        "correctStrike": correctStrike = 0,
                      });
                      Get.back(); // Close the dialog
                      _animationController.reset();
                      _animationController.forward().whenComplete(nextQuestion);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final savedWordsQuerySnapshot = await FirebaseFirestore
                          .instance
                          .collection("Profile")
                          .doc(docID)
                          .collection("savedWords")
                          .get();

                      await FirebaseFirestore.instance
                          .collection('Profile')
                          .doc(docID)
                          .update(
                              {'wordLength': savedWordsQuerySnapshot.size - 1});

                      await subcollectionReference
                          .doc(
                              '${_questions[_questionNumber.value - 1].question}')
                          .delete();
                      Get.back(); // Close the dialog
                      _animationController.reset();
                      _animationController.forward().whenComplete(nextQuestion);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      try {
        await subcollectionReference
            .doc('${_questions[_questionNumber.value - 1].question}')
            .update({
          'answerCorrect': answerCorrectCount + 1,
          "correctStrike": correctStrike + 1,
        });
      } catch (e) {
        print("Error updating answerCorrect in Firebase: $e");
      }
    } else {
      try {
        if (answerWrongCount > 0) {
          await subcollectionReference
              .doc('${_questions[_questionNumber.value - 1].question}')
              .update({'answerWrong': answerWrongCount - 1});
        }
      } catch (e) {
        print("Error updating answerCorrect in Firebase: $e");
      }
    }
  }

  Future<void> updateAnswerWrongInFirebase(
      int answerCorrectCount, int answerWrongCount, int correctStrike) async {
    try {
      final subcollectionReference = FirebaseFirestore.instance
          .collection('Profile')
          .doc(docID)
          .collection("savedWords");

      await subcollectionReference
          .doc('${_questions[_questionNumber.value - 1].question}')
          .update({
        'answerWrong': answerWrongCount + 1,
        "correctStrike": 0,
      });
    } catch (e) {
      print("Error updating answerCorrect in Firebase: $e");
    }
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }

  void resetPageController() {
    _pageController.dispose(); // Dispose the existing controller
    _pageController = PageController(); // Create a new controller
  }

  void updateSavedWordsData(boolIn) {
    savedWordsData = boolIn;
  }

  void resetQuiz() {
    _questionNumber.value = 1;
    _questionNumber = 1.obs;
    _numOfCorrectAns = 0;
    _isAnswered = false;
    resetPageController();
    _animationController.reset();
    _animationController.stop();
  }

  void startTimer() {
    // Start the animation again
    _animationController.forward().whenComplete(nextQuestion);
  }

  void getNumberOfQuestion(getnumber) {
    numberOfQuestion = getnumber;
  }
}
