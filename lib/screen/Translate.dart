import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:reslate/model/languageChange.dart';
import 'package:reslate/model/profile.dart';
import 'package:reslate/screen/menu.dart';
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
  var raw, words;
  List<String> wordsList = [];
  var inputLanguage = 'en';
  var outputLanguage = 'th';
  String label = "English";
  String inputbox = "Enter text";
  String outputbox = "คำแปล";
  var rawtxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebase = Firebase.initializeApp();
    CollectionReference<Map<String, dynamic>> userCollection =
        FirebaseFirestore.instance.collection("Profile");
    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Translate",
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade50,
        leading: IconButton(
          icon: Icon(
            Icons.translate,
            color: Colors.blue,
          ),
          onPressed: () {
            if (inputLanguage == 'en' || inputLanguage == null) {
              language.input = 'th';
              language.output = 'en';
              language.label = "ภาษาไทย";
              language.inbox = "โปรดป้อนข้อความ";
              language.outbox = 'Translated';
            } else {
              language.input = 'en';
              language.output = 'th';
              language.label = "English";
              language.inbox = "Enter text";
              language.outbox = 'คำแปล';
            }
            changeLanguage();
            wordsList.clear();
          },
        ),
      ),
      body: Card(
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
                  for (int i = 0; i < wordsList.length; i += 5)
                    Row(
                      children: [
                        for (int j = i; j < i + 5 && j < wordsList.length; j++)
                          Flexible(
                            child: TextButton(
                              onPressed: () async {
                                rawtxt.text = wordsList[j];
                                await translator
                                    .translate(rawtxt.text,
                                        from: inputLanguage, to: outputLanguage)
                                    .then((translation) {
                                  setState(() {
                                    translated = translation.toString();
                                    wordsList.clear();
                                  });
                                });
                              },
                              child: Text(
                                wordsList[j],
                                style: TextStyle(color: Colors.black54),
                              ),
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
            try {
              if (rawtxt.text.isNotEmpty &&
                  translated != "คำแปล" &&
                  translated != "Translated") {
                try {
                  // await userDocumentRef.update({
                  //   'words':
                  //       FieldValue.arrayUnion(["${rawtxt.text},$translated"]),
                  // });

                  String newDocumentId = rawtxt.text;
                  DocumentReference<Map<String, dynamic>> newDocumentRef =
                      userCollection
                          .doc(widget.docID)
                          .collection("savedWords")
                          .doc(newDocumentId);
                  Map<String, dynamic> dataToStore = {
                    'inputText': rawtxt.text,
                    'translatedText': translated,
                    'beQuestion': 0,
                    'answerWrong': 0,
                  };
                  await newDocumentRef.set(dataToStore);

                  DocumentSnapshot<Map<String, dynamic>> userDoc =
                      await userDocumentRef.get();

                  int currentWordLength = userDoc.data()?['wordLength'] ?? 0;
                  int newWordLength = currentWordLength + 1;
                  await userDocumentRef.update({'wordLength': newWordLength});

                  DocumentSnapshot documentSnapshot =
                      await userDocumentRef.get();
                  Map<String, dynamic>? data =
                      documentSnapshot.data() as Map<String, dynamic>?;
                  if (data != null) {
                    profile.data = data;
                    widget.sendData(data);
                  } else {
                    print('Data is null or not a Map<String, dynamic>');
                  }
                } catch (e) {
                  print(e);
                }
                ;
                Fluttertoast.showToast(
                    msg: "บันทึกคำศัพท์เรียบร้อย", gravity: ToastGravity.TOP);
              } else {
                Fluttertoast.showToast(
                    msg: "กรุณาป้อนคำศัพท์เพื่อบันทึก",
                    gravity: ToastGravity.TOP);
              }
            } catch (e) {
              print(e);
            }
          },
          child: Icon(Icons.upload),
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
    } else {
      inputLanguage = language.input;
      outputLanguage = language.output;
      label = language.label;
      inputbox = language.inbox;
      translated = language.outbox;
    }
    setState(() {});
    rawtxt.clear();
  }
}
