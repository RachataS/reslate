import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/screens/bottomBar.dart';
import '/constants.dart';
import '/controllers/question_controller.dart';
import 'package:flutter_svg/svg.dart';

class ScoreScreen extends StatelessWidget {
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
                          onPressed: () {
                            _qnController.correctAnswer = 0;
                            Get.to(bottombar());
                          },
                          child: Text("return")),
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
