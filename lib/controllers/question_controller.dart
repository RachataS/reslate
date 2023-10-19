import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:reslate/models/getDocument.dart';
import '/models/Questions.dart';
import '/screens/score/score_screen.dart';

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

  late bool? savedWordsData;
  QuestionController({this.savedWordsData}) {
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
      var answerCorrect, answerWrong;

      if (data != null && data.containsKey('answerCorrect')) {
        answerCorrect = data['answerCorrect'];
        answerWrong = data['answerWrong'];
      }
      try {
        if (_correctAns == _selectedAns) {
          await updateAnswerCorrectInFirebase(answerCorrect, answerWrong);
        } else {
          await updateAnswerWrongInFirebase(answerCorrect, answerWrong);
          resetQuiz();
          Get.to(() => ScoreScreen());
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
        resetQuiz();
        Get.to(() => ScoreScreen());
        return;
      }

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once the timer is finished, go to the next question
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      // All questions answered, go to the ScoreScreen
      resetQuiz();
      Get.to(() => ScoreScreen());
    }
  }

  Future<void> updateAnswerCorrectInFirebase(
      int answerCorrectCount, int answerWrongCount) async {
    final subcollectionReference = FirebaseFirestore.instance
        .collection('Profile')
        .doc(docID)
        .collection("savedWords");

    if (savedWordsData == true) {
      if (answerCorrectCount >= 3) {
        // Reset the count
        // Show a dialog when answerCorrectCount is greater than or equal to 3
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
                              '${_questions[_questionNumber.value - 2].question}')
                          .update({'answerCorrect': answerCorrectCount = 1});
                      Get.back(); // Close the dialog
                      _animationController.reset();
                      _animationController.forward().whenComplete(nextQuestion);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('Profile')
                          .doc(docID)
                          .update({'wordLength': questions.length - 1});

                      await subcollectionReference
                          .doc(
                              '${_questions[_questionNumber.value - 2].question}')
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
            .update({'answerCorrect': answerCorrectCount + 1});
      } catch (e) {
        print("Error updating answerCorrect in Firebase: $e");
      }
    } else if (savedWordsData == false) {
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
      int answerCorrectCount, int answerWrongCount) async {
    try {
      final subcollectionReference = FirebaseFirestore.instance
          .collection('Profile')
          .doc(docID)
          .collection("savedWords");

      await subcollectionReference
          .doc('${_questions[_questionNumber.value - 1].question}')
          .update({'answerWrong': answerWrongCount + 1});
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

  void resetQuiz() {
    _questionNumber.value = 1;
    _questionNumber = 1.obs;
    _numOfCorrectAns = 0;
    _isAnswered = false;
    resetPageController();
    _animationController.reset();
    _animationController.stop();
  }

  //  Future<void> quizDialog() async {
  //   double dialogWidth = 300;
  //   double dialogHeight = 300;

  //   Dialog saveWordsDialog = Dialog(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Container(
  //       width: dialogWidth,
  //       height: dialogHeight,
  //       child: Padding(
  //         padding: const EdgeInsets.all(10),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               'show',
  //               textAlign: TextAlign.center,
  //               style: TextStyle(fontSize: 25),
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),

  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   showDialog(
  //       context: context, builder: (BuildContext context) => saveWordsDialog);
  // }
}
