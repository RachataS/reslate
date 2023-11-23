import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/screens/review/multipleChoice/components/body.dart';
import 'dart:math' as math;

class multipleChoice extends StatefulWidget {
  final String? docID;
  final bool? savedWordsData;
  late int? numberOfQuestion;
  multipleChoice({
    this.docID,
    this.savedWordsData,
    this.numberOfQuestion,
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  margin: const EdgeInsets.all(10),
                  color: Colors.blue[300]!,
                  child: TextButton(
                    onPressed: _controller.nextQuestion,
                    child: SizedBox(
                      width: 80,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.rotationY(math.pi), // Flip horizontally
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
                    onPressed: () {},
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
                            "3/3",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
