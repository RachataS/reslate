import 'package:flutter/material.dart';
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
    return Scaffold(
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
                margin: const EdgeInsets.only(bottom: 10), // Adjust this margin
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
                                  child: Text(
                                    'Wrong: ${filteredWords[index]['answerWrong']}',
                                    style: TextStyle(fontSize: 16),
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
    );
  }
}
