import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/screens/review/multipleChoice/score_screen.dart';
import 'dart:math' as math;

class appbar extends StatefulWidget {
  final String? docID;
  final bool savedWordsData;
  late int? numberOfQuestion;
  late int? aids;
  appbar({
    super.key,
    this.docID,
    required this.savedWordsData,
    this.numberOfQuestion,
    this.aids,
  });

  @override
  State<appbar> createState() => _appbarState();
}

class _appbarState extends State<appbar> {
  QuestionController _controller = Get.put(QuestionController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.all(10),
          color: Colors.blue[300]!,
          child: TextButton(
            onPressed: () async {
              _controller.resetQuiz();
              Get.to(
                  () => ScoreScreen(
                        savedWordsData: widget.savedWordsData,
                        numberOfQuestion: widget.numberOfQuestion,
                        docID: widget.docID,
                      ),
                  transition: Transition.topLevel);
            },
            child: SizedBox(
              width: 80,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi), // Flip horizontally
                    child: Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Exit",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        Spacer(), // Add Spacer to push Helper button to the right
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.all(10),
          color: Colors.orange[300]!,
          child: TextButton(
            onPressed: () async {
              if (widget.aids! > 0) {
                _controller.stopEverything();
                _controller.startTimer();
                await FirebaseFirestore.instance
                    .collection('Profile')
                    .doc(widget.docID)
                    .update({'aids': widget.aids! - 1});

                setState(() {
                  // setState reset หน้าทำให้ reset
                  widget.aids = widget.aids! - 1;
                });
              }
            },
            child: SizedBox(
              width: 80,
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_alarm_outlined,
                    color: Colors.black,
                    size: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "${widget.aids}/3",
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
