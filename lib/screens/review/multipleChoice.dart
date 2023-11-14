import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/review/components/body.dart';

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

  @override
  void initState() {
    super.initState();
    print("from multi = ${widget.savedWordsData}");
  }

  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());

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
