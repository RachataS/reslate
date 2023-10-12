import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:reslate/models/languageChange.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/screens/menu.dart';
import 'package:translator/translator.dart';
import 'dart:convert';

class translate_screen extends StatefulWidget {
  final String? docID;
  final Function(Map<String, dynamic>) sendData;

  translate_screen({required this.docID, required this.sendData});

  @override
  State<translate_screen> createState() => _translate_screenState();
}

class _translate_screenState extends State<translate_screen> {
  final formKey = GlobalKey<FormState>();
  GoogleTranslator translator = GoogleTranslator();
  languageChange language = languageChange();
  String translated = "คำแปล";
  Profile profile = Profile();
  List<String> wordsList = [];
  var inputLanguage = 'en';
  var outputLanguage = 'th';
  String label = "English";
  String inputbox = "Enter text";
  String outputbox = "คำแปล";
  List<String> selecttxt = [];
  List<String> selecttranslated = [];
  var rawtxt = TextEditingController();
  var appbarInput = "English";
  var appbarOutput = "Thai";
  List<String> wordsListWithoutDuplicates = [];
  int checkWords = 0;

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebase = Firebase.initializeApp();

    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
            decoration: BoxDecoration(
                color: Colors.blue[400]!,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                    bottomRight: Radius.circular(60))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 120,
                  child: Text(
                    appbarInput,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: CircleBorder()),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.swap_horiz_outlined,
                        color: Colors.blue[400]!),
                  ),
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    if (inputLanguage == 'en' || inputLanguage == null) {
                      language.input = 'th';
                      language.output = 'en';
                      language.label = "ภาษาไทย";
                      language.inbox = "โปรดป้อนข้อความ";
                      language.outbox = 'Translated';
                      language.appbarInput = "Thai";
                      language.appberOutput = "English";
                    } else {
                      language.input = 'en';
                      language.output = 'th';
                      language.label = "English";
                      language.inbox = "Enter text";
                      language.outbox = 'คำแปล';
                      language.appbarInput = "English";
                      language.appberOutput = "Thai";
                    }
                    changeLanguage();
                    wordsList.clear();
                    wordsListWithoutDuplicates.clear();
                  },
                ),
                Container(
                  alignment: Alignment.center,
                  width: 120,
                  child: Text(
                    appbarOutput,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )),
      ),
      body: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        key: formKey,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(label),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: inputbox,
              ),
              controller: rawtxt,
              maxLines: null,
              onChanged: (rawtxt) async {
                if (rawtxt == null || rawtxt == '') {
                  setState(() {
                    translated = outputbox;
                  });
                  wordsList.clear();
                  wordsListWithoutDuplicates.clear();
                } else {
                  try {
                    formKey.currentState?.save();
                    await translator
                        .translate('${rawtxt}',
                            from: inputLanguage, to: outputLanguage)
                        .then((translation) {
                      // Future.delayed(Duration(milliseconds: 500), () {
                      setState(() {
                        translated = translation.toString();
                        if (rawtxt.contains(' ')) {
                          wordsList = rawtxt.split(' ');
                        }
                        // });
                      });
                    });
                  } catch (e) {
                    print(e);
                  }
                }
                wordsListWithoutDuplicates =
                    List<String>.from(wordsList.toSet());
              },
            ),
            const Divider(
              height: 32,
            ),
            Text(
              translated,
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Column(
                children: [
                  for (int i = 0; i < wordsListWithoutDuplicates.length; i += 5)
                    Row(
                      children: [
                        for (int j = i;
                            j < i + 5 && j < wordsListWithoutDuplicates.length;
                            j++)
                          Flexible(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      if (selecttxt.contains(
                                          wordsListWithoutDuplicates[j])) {
                                        selecttxt.remove(
                                            wordsListWithoutDuplicates[j]);
                                        checkWords--;
                                      } else {
                                        selecttxt
                                            .add(wordsListWithoutDuplicates[j]);
                                        checkWords++;
                                      }
                                    });
                                  },
                                  child: Text(
                                    wordsListWithoutDuplicates[j],
                                    style: TextStyle(
                                      color: selecttxt.contains(
                                              wordsListWithoutDuplicates[j])
                                          ? Colors.blue[400]
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                if (selecttxt
                                    .contains(wordsListWithoutDuplicates[j]))
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors
                                          .red, // You can change the color
                                    ),
                                    child: Text(
                                      (selecttxt.indexOf(
                                                  wordsListWithoutDuplicates[
                                                      j]) +
                                              1)
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: FloatingActionButton(
          onPressed: () async {
            if (selecttxt.length > 0) {
              dialogTranslate();
            } else {
              QuerySnapshot<Map<String, dynamic>> oldWordLengthQury =
                  await FirebaseFirestore.instance
                      .collection("Profile")
                      .doc(widget.docID)
                      .collection("savedWords")
                      .get();
              var oldWordLength = oldWordLengthQury.size;
              saveWords(rawtxt.text, translated, oldWordLength);
            }
          },
          child: Icon(
            selecttxt.isNotEmpty ? Icons.translate : Icons.bookmark,
          ),
        ),
      ),
    );
  }

  changeLanguage() {
    formKey.currentState?.reset();
    if (inputLanguage == null) {
      inputLanguage = 'en';
      outputLanguage = 'th';
      label = "English";
      inputbox = "Enter text";
      outputbox = "คำแปล";
      appbarInput = "English";
      appbarOutput = "Thai";
    } else {
      inputLanguage = language.input;
      outputLanguage = language.output;
      label = language.label;
      inputbox = language.inbox;
      translated = language.outbox;
      appbarInput = language.appbarInput;
      appbarOutput = language.appberOutput;
    }
    setState(() {});
    rawtxt.clear();
  }

  Future<void> saveWords(eng, thai, id) async {
    CollectionReference<Map<String, dynamic>> userCollection =
        FirebaseFirestore.instance.collection("Profile");
    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);

    try {
      if (eng.trim().isNotEmpty && thai.trim().isNotEmpty) {
        if (!eng.contains(" ") && !thai.contains(" ")) {
          if (!containsSpecialChars(eng) && !containsSpecialChars(thai)) {
            try {
              eng = eng.toLowerCase();
              thai = thai.toLowerCase();

              if (RegExp(r'[^a-zA-Z]').hasMatch(eng)) {
                //save from thai translate
                String newDocumentId = thai;
                DocumentReference<Map<String, dynamic>> newDocumentRef =
                    userCollection
                        .doc(widget.docID)
                        .collection("savedWords")
                        .doc(newDocumentId);
                Map<String, dynamic> dataToStore = {
                  'id': id += 1,
                  'thai': eng,
                  'question': thai,
                  'answerWrong': 0,
                  'answerCorrect': 0,
                  "options": [],
                  "answer_index": 0
                };
                await newDocumentRef.set(dataToStore);
              } else {
                //save from eng translate
                String newDocumentId = eng;
                DocumentReference<Map<String, dynamic>> newDocumentRef =
                    userCollection
                        .doc(widget.docID)
                        .collection("savedWords")
                        .doc(newDocumentId);
                Map<String, dynamic> dataToStore = {
                  'id': id += 1,
                  'question': eng,
                  'thai': thai,
                  'answerWrong': 0,
                  'answerCorrect': 0,
                  "options": [],
                  "answer_index": 0
                };
                await newDocumentRef.set(dataToStore);
              }
              QuerySnapshot<Map<String, dynamic>> savedWordsQuerySnapshot =
                  await userCollection
                      .doc(widget.docID)
                      .collection("savedWords")
                      .get();
              var newWordLength = savedWordsQuerySnapshot.size;
              await userDocumentRef.update({'wordLength': newWordLength});

              DocumentSnapshot<Map<String, dynamic>> userDoc =
                  await userDocumentRef.get();

              Map<String, dynamic>? data =
                  userDoc.data() as Map<String, dynamic>?;

              if (data != null) {
                profile.data = data;
                widget.sendData(data);
              } else {
                print('Data is null or not a Map<String, dynamic>');
              }
              Fluttertoast.showToast(
                  msg: "บันทึกคำศัพท์เรียบร้อย", gravity: ToastGravity.TOP);
            } catch (e) {
              Fluttertoast.showToast(
                  msg: "ไม่สามารถบันทึกคำศัำท์ได้", gravity: ToastGravity.TOP);
            }
          } else {
            Fluttertoast.showToast(
                msg: "ไม่สามารถบันทึกคำศัพท์ที่มีอักษรพิเศษได้",
                gravity: ToastGravity.TOP);
          }
        } else {
          Fluttertoast.showToast(
              msg: "โปรดเลือกคำศัพท์ที่ต้องการบันทึก",
              gravity: ToastGravity.TOP);
        }
      } else {
        Fluttertoast.showToast(
            msg: "กรุณาป้อนคำศัพท์เพื่อบันทึก", gravity: ToastGravity.TOP);
      }
    } catch (e) {
      print(e);
    }
  }

  bool containsSpecialChars(String text) {
    final specialChars = [
      '.',
      '/',
      '=',
      '|',
      '\\',
      '^',
      '%',
      '\$',
      '#',
      '-',
      '+',
      ',',
      '<',
      '>',
      '@',
      ':',
      ';',
      '\'',
      '\"'
    ];
    for (var char in specialChars) {
      if (text.contains(char)) {
        return true;
      }
    }
    return false;
  }

  Future<void> dialogTranslate() async {
    double dialogWidth = 400;
    double dialogHeight = 200;
    String outputtxt = "";

    if (checkWords > 20) {
      setState(() {
        selecttxt.clear();
        selecttranslated.clear();
        selecttranslated.add("Please select fewer than 20 words!");
        dialogWidth = 250;
        dialogHeight = 200;
        checkWords = 0;
      });
    } else {
      for (int i = 0; i < selecttxt.length; i++) {
        await translator
            .translate(selecttxt[i], from: inputLanguage, to: outputLanguage)
            .then((translation) {
          setState(() {
            selecttranslated.add(selecttxt[i] + " = " + translation.toString());
            dialogHeight += 30;
          });
        });
      }
    }

    Dialog saveWordsDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    '${selecttranslated.join("\n")}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selecttxt.clear();
                          selecttranslated.clear();
                          checkWords = 0;
                        });
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        for (int i = 0; i < selecttranslated.length; i++) {
                          String translation = selecttranslated[i];
                          List<String> parts = translation.split('=');

                          if (parts.length == 2) {
                            QuerySnapshot<Map<String, dynamic>>
                                oldWordLengthQury = await FirebaseFirestore
                                    .instance
                                    .collection("Profile")
                                    .doc(widget.docID)
                                    .collection("savedWords")
                                    .get();
                            var oldWordLength = oldWordLengthQury.size;
                            String eng = parts[0].trim();
                            String thai = parts[1].trim();

                            saveWords(eng, thai, oldWordLength);
                          }
                        }

                        setState(() {
                          selecttxt.clear();
                          selecttranslated.clear();
                          checkWords = 0;
                        });
                      },
                      style: TextButton.styleFrom(
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => saveWordsDialog,
    );
  }
}