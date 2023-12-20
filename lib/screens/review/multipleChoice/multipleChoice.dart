import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/screens/review/multipleChoice/components/appbar.dart';
import 'package:reslate/screens/review/multipleChoice/components/body.dart';
import 'dart:math' as math;

import 'package:reslate/screens/review/multipleChoice/score_screen.dart';

class multipleChoice extends StatefulWidget {
  final String? docID;
  final bool savedWordsData;
  late int? numberOfQuestion;
  late int? aids;
  multipleChoice({
    this.docID,
    required this.savedWordsData,
    this.numberOfQuestion,
    this.aids,
  });

  @override
  State<multipleChoice> createState() => _multipleChoiceState();
}

class _multipleChoiceState extends State<multipleChoice> {
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("Profile");

  firebaseDoc firebasedoc = firebaseDoc();
  QuestionController _controller = Get.put(QuestionController());

  @override
  void initState() {
    super.initState();
    print("from multi = ${widget.savedWordsData}");
  }

  Widget build(BuildContext context) {
    _controller.updateSavedWordsData(widget.savedWordsData);
    _controller.startTimer();
    _controller.getNumberOfQuestion(widget.numberOfQuestion);

    return WillPopScope(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: appbar(
              docID: widget.docID,
              savedWordsData: true,
              numberOfQuestion: widget.numberOfQuestion,
              aids: widget.aids,
            ),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future:
                firebasedoc.getQuestion(widget.docID, widget.savedWordsData),
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
}
