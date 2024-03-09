import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reslate/models/languageChange.dart';
import 'package:reslate/models/profile.dart';

import 'package:translator/translator.dart';

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

  int checkWords = 0;
  bool isButtonDisabled = false;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: screenSize.width / 4,
                    child: Text(
                      appbarInput,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 19,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: CircleBorder()),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue[400]!,
                      child:
                          Icon(Icons.swap_horiz_outlined, color: Colors.white),
                    ),
                    onPressed: () {
                      // SystemSound.play(SystemSoundType.click);
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
                    },
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: screenSize.width / 4,
                    child: Text(
                      appbarOutput,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 19,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              )),
        ),
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
          child: Padding(
            padding:
                EdgeInsets.only(top: screenSize.height * 0.10), //for ios 0.12
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              key: formKey,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 110),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(label),
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: inputbox,
                    ),
                    controller: rawtxt,
                    maxLines: null,
                    onChanged: (rawtxt) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 500), () async {
                        if (rawtxt == null || rawtxt.isEmpty) {
                          setState(() {
                            translated = outputbox;
                          });
                          wordsList.clear();
                          wordsList.clear();
                        } else {
                          try {
                            formKey.currentState?.save();
                            await translator
                                .translate(rawtxt,
                                    from: inputLanguage, to: outputLanguage)
                                .then((translation) {
                              setState(() {
                                translated = translation.toString();
                                //หากเจอการเว้นวรรคในประโยคจะเพิ่มลงใน WordsList
                                if (rawtxt.contains(' ')) {
                                  wordsList = rawtxt.toLowerCase().split(' ');
                                }
                              });
                            });
                          } catch (e) {
                            print(e);
                          }
                        }
                        // แยกตัวอักษรพิเศษออกจากคำศัพท์ใน wordsList
                        wordsList = splitSpecialChars(wordsList);
                        // ลบคำศัพท์ที่ซ้ำกันใน wordsList โดยการแปลง wordsList เป็น Set เพื่อลบคำที่ซ้ำกัน แล้วแปลงกลับเป็น List
                        wordsList = List<String>.from(wordsList.toSet());
                        // เรียงลำดับคำศัพท์ใน wordsList ตามลำดับอักขระ
                        wordsList.sort();
                      });
                    },
                  ),
                  const Divider(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    translated,
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < wordsList.length; i += 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ใช้ loop เพื่อสร้างปุ่ม TextButton สำหรับแสดงคำศัพท์
                                for (int j = i;
                                    j < i + 3 && j < wordsList.length;
                                    j++)
                                  Flexible(
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                if (selecttxt
                                                    .contains(wordsList[j])) {
                                                  // หรือถ้าคำศัพท์ถูกยกเลิกการเลือก จะลบออกจาก selecttxt และลดจำนวนคำที่ถูกเลือก
                                                  selecttxt
                                                      .remove(wordsList[j]);
                                                  checkWords--;
                                                } else {
                                                  // เมื่อคำศัพท์ถูกเลือก จะทำการเพิ่มลงใน selecttxt และเพิ่มจำนวนคำที่ถูกเลือก
                                                  selecttxt.add(wordsList[j]);
                                                  checkWords++;
                                                }
                                              });
                                            },
                                            //แสดงคำศัพท์บนปุ่ม
                                            child: Text(
                                              wordsList[j],
                                              style: TextStyle(
                                                fontSize:
                                                    wordsList[j].length > 5
                                                        ? 14
                                                        : 15,
                                                color: selecttxt
                                                        .contains(wordsList[j])
                                                    ? Colors.blue[400]
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
// ตรวจสอบว่าคำศัพท์ใน selecttxt ถูกเลือกหรือไม่
                                        if (selecttxt.contains(wordsList[j]))

                                          // หากคำศัพท์ถูกเลือก จะสร้าง Widget Container เพื่อแสดงหมายเลขลำดับที่คำศัพท์ถูกเลือกอยู่
                                          Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors
                                                  .red, // กำหนดสีของวงกลมเป็นสีแดง
                                            ),
                                            child: Text(
                                              (selecttxt.indexOf(wordsList[j]) +
                                                      1)
                                                  .toString(), // แสดงเลขลำดับที่คำศัพท์ถูกเลือก
                                              style: TextStyle(
                                                color: Colors
                                                    .white, // กำหนดสีของตัวอักษรเป็นสีขาว
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
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (!isButtonDisabled) {
                  // Disable the button
                  setState(() {
                    isButtonDisabled = true;
                  });

                  if (selecttxt.length > 0) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                    await dialogTranslate();
                  } else {
                    QuerySnapshot<Map<String, dynamic>> oldWordLengthQury =
                        await FirebaseFirestore.instance
                            .collection("Profile")
                            .doc(widget.docID)
                            .collection("savedWords")
                            .get();
                    var oldWordLength = oldWordLengthQury.size;
                    await saveWords(rawtxt.text, translated, oldWordLength);
                  }

                  setState(() {
                    isButtonDisabled = false;
                  });
                }
              },
              child: Icon(
                selecttxt.isNotEmpty ? Icons.translate : Icons.bookmark,
                color: Colors.white,
              ),
            )),
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
                  "answer_index": 0,
                  "correctStrike": 0,
                  "beQuestion": false,
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
                  "answer_index": 0,
                  "correctStrike": 0,
                  "beQuestion": false,
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
      '\"',
      '\n',
      '!',
      '(',
      ')',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '?',
    ];

    for (var char in specialChars) {
      if (text.contains(char)) {
        return true;
      }
    }
    return false;
  }

  List<String> splitSpecialChars(List<String> words) {
    final List<String> specialChars = [
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
      '\"',
      '\n',
      '!',
      '(',
      ')',
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '?',
    ];

    List<String> wordsWithoutSpecialChars = [];
    for (var word in words) {
      // Split the word into individual words using special characters and space
      List<String> splitWords =
          word.split(RegExp(r'[\s' + specialChars.join('') + ']+'));
      for (var splitWord in splitWords) {
        String wordWithoutSpecialChars = splitWord;
        for (var char in specialChars) {
          wordWithoutSpecialChars =
              wordWithoutSpecialChars.replaceAll(char, '');
        }
        if (wordWithoutSpecialChars.isNotEmpty) {
          wordsWithoutSpecialChars.add(wordWithoutSpecialChars);
        }
      }
    }

    return wordsWithoutSpecialChars;
  }

  Future<void> dialogTranslate() async {
    double dialogWidth = 400;
    double dialogHeight = 200;

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
      backgroundColor: Colors.blue[100]!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Adjust the radius as needed
      ),
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
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Center(
                          child: CircularProgressIndicator(),
                        );
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

                            await saveWords(eng, thai, oldWordLength);
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
                      child: Text(
                        'Bookmark',
                        style: TextStyle(color: Colors.blue[800]!),
                      ),
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
    ).then((value) {
      if (value == null) {
        setState(() {
          // selecttxt.clear();
          // selecttranslated.clear();
          // checkWords = 0;
          Navigator.of(context).pop();
        });
      }
    });
  }
}
