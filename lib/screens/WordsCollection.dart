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
  List<Map<String, dynamic>> selectedWords = [];

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
                      return SizedBox(
                        height: 135,
                        child: Card(
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
                                      child: Row(
                                        children: [
                                          Text(
                                            '${filteredWords[index]['thai']}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                toggleSelectWord(index);
                                              });
                                            },
                                            icon: Icon(Icons
                                                .check_circle_outline_outlined),
                                            color: isSelected(index)
                                                ? Colors
                                                    .green // Change to green when selected
                                                : Colors.grey,
                                          )
                                        ],
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
                                          // if (selectedWords.isEmpty)
                                          IconButton(
                                            onPressed: () {
                                              // If the word is selected, remove it from selectedWords
                                              if (isSelected(index)) {
                                                setState(() {
                                                  selectedWords.removeWhere(
                                                      (word) =>
                                                          word['question'] ==
                                                          filteredWords[index]
                                                              ['question']);
                                                });
                                              }
                                              // Now, proceed with the deleteWord function
                                              deleteWord(index);
                                            },
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
        floatingActionButton: selectedWords.isNotEmpty
            ? FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                backgroundColor: Colors.red,
                onPressed: () async {
                  await deleteSelectedWords();
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  void toggleSelectWord(int index) {
    if (isSelected(index)) {
      selectedWords.removeWhere(
          (word) => word['question'] == filteredWords[index]['question']);
    } else {
      selectedWords.add({'question': filteredWords[index]['question']});
    }
  }

  bool isSelected(int index) {
    return selectedWords
        .any((word) => word['question'] == filteredWords[index]['question']);
  }

  Future<void> deleteSelectedWords() async {
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
        title: Text('Do you want to delete the selected words?'),
        content: Text('If you delete the selected words, they will disappear.'),
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

                  for (var word in selectedWords) {
                    await subcollectionReference
                        .doc('${word['question']}')
                        .delete();
                    await FirebaseFirestore.instance
                        .collection('Profile')
                        .doc(docID)
                        .update(
                            {'wordLength': savedWordsQuerySnapshot.size - 1});
                  }
                  selectedWords.clear();
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
