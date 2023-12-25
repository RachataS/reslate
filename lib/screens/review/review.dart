import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/screens/review/multipleChoice/multipleChoice.dart';
import 'package:reslate/screens/review/matchCard/widgets/game_options.dart';

class reviewPage extends StatefulWidget {
  final String? docID;
  final Profile profile;

  reviewPage({required this.docID, required this.profile});

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  firebaseDoc firebasedoc = firebaseDoc();
  var numberOfQuestion = 10;

  @override
  void initState() {
    super.initState();
    checkArchive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blue[600]!,
            Colors.blue[300]!,
            Colors.blue[100]!,
            // Colors.blue[50]!,
          ]),
        ),
        child: PageView(
          scrollDirection: Axis.horizontal,
          children: [savedWordsMode(), WroongAnswerMode()],
        ),
      ),
    );
  }

  Scaffold savedWordsMode() {
    int wordsLength = widget.profile.data?['wordLength'];
    int aids = widget.profile.data?["aids"];
    if (wordsLength < 10) {
      numberOfQuestion = 0;
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Text(
                "Saved Words",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 20),
                child: Column(
                  children: [
                    Text(
                      'Multiple Choice',
                      style: TextStyle(
                        color: (wordsLength >= 10 ? Colors.blue : Colors.red),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 10;
                              if (wordsLength >= 10) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '10',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 10
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 10
                                  ? Colors.red
                                  : (numberOfQuestion == 10
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 20;
                              if (wordsLength >= 20) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '20',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 20
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 20
                                  ? Colors.red
                                  : (numberOfQuestion == 20
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 40;
                              if (wordsLength >= 40) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '40',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 40
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 40
                                  ? Colors.red
                                  : (numberOfQuestion == 40
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 60;
                              if (wordsLength >= 60) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '60',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 60
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 60
                                  ? Colors.red
                                  : (numberOfQuestion == 60
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            // SystemSound.play(SystemSoundType.click);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            int savedWords = await firebasedoc.getSavedWords(
                                numberOfQuestion, true, widget.docID);

                            Navigator.of(context, rootNavigator: true).pop();

                            if (wordsLength >= 10) {
                              if (numberOfQuestion <= savedWords) {
                                Get.to(
                                    multipleChoice(
                                      docID: widget.docID,
                                      savedWordsData: true,
                                      numberOfQuestion: numberOfQuestion,
                                      aids: aids,
                                    ),
                                    transition: Transition.topLevel);
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "คุณมีคำศัพท์ไม่ถึง 10 คำ",
                                  gravity: ToastGravity.TOP);
                            }
                          },
                          child: Text(
                            "Let’s play",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: (wordsLength >= 10
                                  ? Colors.blue
                                  : Colors.red),
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 20),
                child: Column(
                  children: [
                    Text(
                      'Match Card',
                      style: TextStyle(
                        color: (wordsLength >= 70 ? Colors.blue : Colors.red),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: GameOptions(
                          profile: widget.profile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              child: Text(
                "Note : This mode takes the user's recorded words and turns them into questions.",
                style: TextStyle(color: Colors.blue[600]!, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.blue[600]!,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.blue[300]!,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold WroongAnswerMode() {
    int wordsLength = widget.profile.data?['wordLength'];
    int aids = widget.profile.data?["aids"];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Text(
                "Wrong Answer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 20),
                child: Column(
                  children: [
                    Text(
                      'Multiple Choice',
                      style: TextStyle(
                        color: (wordsLength >= 10 ? Colors.blue : Colors.red),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 10;
                              if (wordsLength >= 10) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '10',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 10
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 10
                                  ? Colors.red
                                  : (numberOfQuestion == 10
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 20;
                              if (wordsLength >= 20) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '20',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 20
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 20
                                  ? Colors.red
                                  : (numberOfQuestion == 20
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 40;
                              if (wordsLength >= 40) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '40',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 40
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 40
                                  ? Colors.red
                                  : (numberOfQuestion == 40
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              numberOfQuestion = 60;
                              if (wordsLength >= 60) {
                                setState(() {});
                              }
                            },
                            child: Text(
                              '60',
                              style: TextStyle(
                                fontSize: 16,
                                color: numberOfQuestion == 60
                                    ? Colors.white
                                    : Colors.blue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wordsLength < 60
                                  ? Colors.red
                                  : (numberOfQuestion == 60
                                      ? Colors.blue[400]
                                      : Colors.white),
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            // SystemSound.play(SystemSoundType.click);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            int savedWords = await firebasedoc.getSavedWords(
                                numberOfQuestion, false, widget.docID);

                            Navigator.of(context, rootNavigator: true).pop();
                            if (wordsLength >= 10) {
                              if (numberOfQuestion <= savedWords) {
                                Get.to(
                                    multipleChoice(
                                      docID: widget.docID,
                                      savedWordsData: false,
                                      numberOfQuestion: numberOfQuestion,
                                      aids: aids,
                                    ),
                                    transition: Transition.topLevel);
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: "คุณมีคำศัพท์ไม่ถึง 10 คำ",
                                  gravity: ToastGravity.TOP);
                            }
                          },
                          child: Text(
                            "Let’s play",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: (wordsLength >= 10
                                  ? Colors.blue
                                  : Colors.red),
                              fixedSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 10, 20),
                child: Column(
                  children: [
                    Text(
                      'Match Card',
                      style: TextStyle(
                        color: (wordsLength >= 70 ? Colors.blue : Colors.red),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 250,
                        child: GameOptions(
                          profile: widget.profile,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              child: Text(
                "Note : This mode takes the words that the user answered incorrectly and turns them into questions.",
                style: TextStyle(color: Colors.blue[600]!, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.blue[300]!,
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.blue[600]!,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkArchive() async {
    int archiveLevel = widget.profile.data?["archiveLevel"];
    int wordsLength = widget.profile.data?["wordLength"];

    if (archiveLevel < 2) {
      if (wordsLength >= 50) {
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(widget.docID)
            .update({'archiveLevel': 2});
        await FirebaseFirestore.instance
            .collection('Profile')
            .doc(widget.docID)
            .update({'aids': 1});
      }
    }
  }
}
