import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class multipleChoice extends StatefulWidget {
  final String? docID;
  multipleChoice({required this.docID});

  @override
  State<multipleChoice> createState() => _multipleChoiceState();
}

class _multipleChoiceState extends State<multipleChoice> {
  CollectionReference<Map<String, dynamic>> userCollection =
      FirebaseFirestore.instance.collection("Profile");

  // @override
  // void initState() {
  //   super.initState();
  //   getQuestion();
  // }

  Future<void> getQuestion() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await userCollection.doc(widget.docID).collection("savedWords").get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        Map<String, dynamic> data = document.data();
        print(data);
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "multipleChoice",
            style: TextStyle(color: Colors.blue[400]!),
          ),
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
        ),
        body: Column(
          children: [],
        ));
  }
}
