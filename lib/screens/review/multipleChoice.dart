import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/question_controller.dart';
import 'package:reslate/models/Questions.dart';
import 'package:reslate/screens/review/components/body.dart';

class multipleChoice extends StatefulWidget {
  final String? docID;
  multipleChoice({required this.docID});

  @override
  State<multipleChoice> createState() => _multipleChoiceState();
}

class _multipleChoiceState extends State<multipleChoice> {
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("Profile");

  QuestionController _controller = Get.put(QuestionController());

  @override
  void initState() {
    super.initState();
    getQuestion();
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
      return firestoreData;
    } catch (e) {
      print("Error fetching data: $e");
      return []; // Return an empty list on error
    }
  }

  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Fluttter show the back button automatically
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
              onPressed: _controller.nextQuestion,
              child: Text(
                "Skip",
                style: TextStyle(color: Colors.black),
              )),
        ],
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
    );
  }
}
