import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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
                    getSavedWords();
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

  Future<void> getSavedWords() async {
    List<Map<String, dynamic>> savedWords = [];

    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);
    QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
        await userDocumentRef.collection("savedWords").get();

    // Iterate through the documents in the QuerySnapshot and print their data
    savedWordsQuerySnapshot.docs
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> data = doc.data();

      savedWords.add(data);
    });

    // Check if there are savedWords
    if (savedWords.isNotEmpty) {
      Random random = Random();
      List<String> randomThaiKeys = [];

      // Randomly select a Thai key and an English key from savedWords
      int randomIndex = random.nextInt(savedWords.length);
      Map<String, dynamic> randomWord = savedWords[randomIndex];

      String thaiKey = randomWord['thai'];
      String engKey = randomWord['eng'];
      String thaiKey1, thaiKey2, thaiKey3;

      print('Random Thai Key: $thaiKey');
      print('Random English Key: $engKey');

      // Randomly select a Thai key from other words in the list
      for (int i = 0; i < 3; i++) {
        int randomIndex;
        do {
          randomIndex = random.nextInt(savedWords.length);
        } while (randomThaiKeys.contains(savedWords[randomIndex]['thai']));

        randomThaiKeys.add(savedWords[randomIndex]['thai']);
      }

      thaiKey1 = randomThaiKeys[0];
      thaiKey2 = randomThaiKeys[1];
      thaiKey3 = randomThaiKeys[2];
      saveChoice(engKey, thaiKey, thaiKey1, thaiKey2, thaiKey3);
    } else {
      print('No savedWords available.');
    }
  }

  Future<void> saveChoice(
      question, correctAnswer, answer1, answer2, answer3) async {
    CollectionReference<Map<String, dynamic>> userCollection =
        FirebaseFirestore.instance.collection("Profile");
    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);

    try {
      String newDocumentId = question;
      DocumentReference<Map<String, dynamic>> newDocumentRef = userCollection
          .doc(widget.docID)
          .collection("review")
          .doc(newDocumentId);
      Map<String, dynamic> dataToStore = {
        "question": question,
        "correctAnswer": correctAnswer,
        "anwser1": answer1,
        "answer2": answer2,
        "answer3": answer3
      };
      await newDocumentRef.set(dataToStore);

      QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
          await userCollection.doc(widget.docID).collection("review").get();
    } catch (e) {
      print(e);
    }
  }
}
