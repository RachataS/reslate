import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/getDocument.dart';

class WordsCollection extends StatefulWidget {
  const WordsCollection({Key? key}) : super(key: key);

  @override
  State<WordsCollection> createState() => _WordsCollectionState();
}

class _WordsCollectionState extends State<WordsCollection> {
  firebaseDoc firebasedoc = firebaseDoc();
  var docID, WordsCollection;
  List<dynamic> filteredWords = [];

  @override
  void initState() {
    super.initState();
    getWords();
  }

  Future<void> getWords() async {
    docID = await firebasedoc.getDocumentId();
    WordsCollection = await firebasedoc.getCard(docID, true);
    // Sort WordsCollection by the 'question' field in English
    WordsCollection.sort(
        (a, b) => a['question'].toString().compareTo(b['question'].toString()));
    // Initialize filteredWords with all words initially
    filteredWords = List.from(WordsCollection);
    setState(() {}); // Trigger a rebuild after fetching and sorting data
  }

  void filterWords(String query) {
    setState(() {
      filteredWords = WordsCollection.where((word) => word['question']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.blue[600]!,
                Colors.blue[300]!,
                Colors.blue[100]!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 50, right: 10, left: 10),
            child: Column(
              children: [
                Container(
                  child: TextField(
                    onChanged: filterWords,
                    decoration: InputDecoration(
                      labelText: 'Search by English word',
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredWords.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.all(5),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${index + 1} : ${filteredWords[index]['question']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${filteredWords[index]['thai']}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Correct: ${filteredWords[index]['answerCorrect']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Wrong: ${filteredWords[index]['answerWrong']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () => deleteWord(index),
                                          icon: Icon(Icons.delete),
                                          color: Colors.red,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteWord(index) async {
    final subcollectionReference = FirebaseFirestore.instance
        .collection('Profile')
        .doc(docID)
        .collection("savedWords");

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.red[100]!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        title: Text(
            'Do you want to delete the word ${filteredWords[index]['question']}?'),
        content: Text(
            'If you delete the word, ${filteredWords[index]['question']} will disappear.'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  Get.back(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final savedWordsQuerySnapshot = await FirebaseFirestore
                      .instance
                      .collection("Profile")
                      .doc(docID)
                      .collection("savedWords")
                      .get();

                  await FirebaseFirestore.instance
                      .collection('Profile')
                      .doc(docID)
                      .update({'wordLength': savedWordsQuerySnapshot.size - 1});

                  await subcollectionReference
                      .doc('${filteredWords[index]['question']}')
                      .delete();
                  getWords();
                  Get.back(); // Close the dialog
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    setState(() {});
  }
}
