import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
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

  QuestionController() {
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

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s
    _animationController =
        AnimationController(duration: Duration(seconds: 15), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });
    _animationController.reset();
    // start our animation
    // Once 60s is completed go to the next qn
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  void checkAns(Question question, int selectedIndex) {
    // because once user press any option then it will run
    _isAnswered = true;
    _correctAns = question.answer;
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns) _numOfCorrectAns++;

    // It will stop the counter
    _animationController.stop();
    update();

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

  void nextQuestion() {
    if (_questionNumber.value != _questions.length) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: Duration(milliseconds: 100), curve: Curves.ease);

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once timer is finish go to the next qn
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      // Get package provide us simple way to naviigate another page
      resetQuiz();
      Get.to(() => ScoreScreen());
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
    resetPageController(); // Reset the PageController
    _animationController.reset();
    _animationController.forward().whenComplete(nextQuestion);
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
