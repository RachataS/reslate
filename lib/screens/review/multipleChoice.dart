import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
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

  @override
  void initState() {
    super.initState();
    print("from multi = ${widget.savedWordsData}");
  }

  Widget build(BuildContext context) {
    QuestionController _controller =
        Get.put(QuestionController(numberOfQuestion: widget.numberOfQuestion));

    _controller.updateSavedWordsData(widget.savedWordsData);
    _controller.startTimer();

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
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await userCollection
          .doc(widget.docID)
          .collection("savedWords")
          .where("beQuestion", isEqualTo: true)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Map<String, dynamic> data = document.data();
        if (data['options'] != null && data['options'].length > 1) {
          firestoreData.add(data);
        }
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
}
