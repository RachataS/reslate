import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reslate/screen/review/matchCard.dart';
import 'dart:math';

import 'package:reslate/screen/review/multipleChoice.dart';

class reviewPage extends StatefulWidget {
  final String? docID;

  reviewPage({required this.docID});

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Select Mode",
          style: TextStyle(color: Colors.blue[400]!),
        ),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 80, 15, 15),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        fixedSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      dialogMode(true, false);
                    },
                    icon: Icon(Icons.workspaces_filled),
                    label: Text(" Multiple Choice")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: 250,
                height: 250,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        fixedSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      dialogMode(false, true);
                    },
                    icon: Icon(Icons.apps_rounded),
                    label: Text(" Match Card")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> dialogMode(multiple, card) async {
    Dialog wordSelect = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 300,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (multiple == true)
              Text(
                "Mutiple Choice",
                style: TextStyle(fontSize: 20),
              ),
            if (card == true)
              Text('Match Card', style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    if (multiple == true) {
                      getSavedWords(true, false);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return multipleChoice();
                      }));
                    }
                    if (card == true) {
                      //match card random method
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return matchCard();
                      }));
                    }
                  },
                  child: Text("Saved words"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    if (multiple == true) {
                      getSavedWords(false, true);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return multipleChoice();
                      }));
                    }
                    if (card == true) {
                      //match card random method
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return matchCard();
                      }));
                    }
                  },
                  child: Text("Wrong answer"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      fixedSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => wordSelect);
  }

  Future<void> getSavedWords(correct, wrong) async {
    List<Map<String, dynamic>> savedWords = [];

    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);
    QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await userDocumentRef.collection("savedWords").get();

    savedWordsQuerySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();
      savedWords.add(data);
      print(data);
    });

    if (savedWords.isNotEmpty) {
      var wordLength;
      await userDocumentRef
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> document) {
        if (document.exists) {
          Map<String, dynamic> data = document.data()!;
          wordLength = data["wordLength"];
        }
      }).catchError((error) {
        print("Error getting document: $error");
      });

      Random random = Random();
      List<int> usedIndices = [];
      List<String> randomThaiKeys = [];

      for (int a = 0; a < wordLength; a++) {
        int randomIndex;
        do {
          randomIndex = random.nextInt(savedWords.length);
        } while (usedIndices.contains(randomIndex));

        usedIndices.add(randomIndex);
        Map<String, dynamic> randomWord = savedWords[randomIndex];
        String thaiKey = randomWord['thai'];
        String engKey = randomWord['eng'];
        String thaiKey1, thaiKey2, thaiKey3;

        for (int i = 0; i < 3; i++) {
          int randomIndex;
          do {
            randomIndex = random.nextInt(savedWords.length);
          } while (randomThaiKeys.contains(savedWords[randomIndex]['thai']) &&
              savedWords[randomIndex]['thai'] != thaiKey);

          randomThaiKeys.add(savedWords[randomIndex]['thai']);
        }

        thaiKey1 = randomThaiKeys[0];
        thaiKey2 = randomThaiKeys[1];
        thaiKey3 = randomThaiKeys[2];
        // print(engKey);

        await saveChoice(engKey, thaiKey, thaiKey1, thaiKey2, thaiKey3);
      }
    } else {
      print('No savedWords available.');
    }
  }

  Future<void> saveChoice(
    question,
    correctAnswer,
    answer1,
    answer2,
    answer3,
  ) async {
    CollectionReference<Map<String, dynamic>> userCollection =
        FirebaseFirestore.instance.collection("Profile");

    try {
      String newDocumentId = question;
      DocumentReference<Map<String, dynamic>> newDocumentRef = userCollection
          .doc(widget.docID)
          .collection("savedWords")
          .doc(question);

      List<String> answerArray = [
        question,
        correctAnswer,
        answer1,
        answer2,
        answer3,
      ];

      Map<String, dynamic> dataToStore = {
        "review": answerArray,
      };
      await newDocumentRef.set(dataToStore, SetOptions(merge: true));

      // DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      //     await userCollection
      //         .doc(widget.docID)
      //         .collection("savedWords")
      //         .doc(question)
      //         .get();
      // Map<String, dynamic>? data = documentSnapshot.data();
      // print(data);
    } catch (e) {
      print(e);
    }
  }
}
