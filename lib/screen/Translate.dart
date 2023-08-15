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
  var inputLanguage = 'en';
  var outputLanguage = 'th';
  String label = "English (EN)";
  String inputbox = "Enter text";
  String outputbox = "คำแปล";
  final rawtxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> firebase = Firebase.initializeApp();
    DocumentReference<Map<String, dynamic>> userDocumentRef =
        FirebaseFirestore.instance.collection("Profile").doc(widget.docID);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Translate",
          style: TextStyle(color: Colors.blueGrey),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade50,
        leading: IconButton(
          icon: Icon(
            Icons.translate,
            color: Colors.blueGrey,
          ),
          onPressed: () {
            if (inputLanguage == 'en' || inputLanguage == null) {
              language.input = 'th';
              language.output = 'en';
              language.label = "ไทย (TH)";
              language.inbox = "โปรดป้อนข้อความ";
              language.outbox = 'Translated';
            } else {
              language.input = 'en';
              language.output = 'th';
              language.label = "English (EN)";
              language.inbox = "Enter text";
              language.outbox = 'คำแปล';
            }
            changeLanguage();
          },
        ),
      ),
      body: Card(
        key: formKey,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 200),
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
                hintText: inputbox,
              ),
              controller: rawtxt,
              onChanged: (rawtxt) async {
                if (rawtxt == "") {
                  translated = outputbox;
                } else {
                  try {
                    formKey.currentState?.save();
                    await translator
                        .translate(rawtxt,
                            from: inputLanguage, to: outputLanguage)
                        .then((transaltion) {
                      setState(() {
                        translated = transaltion.toString();
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
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (rawtxt.text.isNotEmpty &&
                translated != "คำแปล" &&
                translated != "Translated") {
              try {
                await userDocumentRef.update({
                  'words':
                      FieldValue.arrayUnion(["${rawtxt.text},$translated"]),
                });
                DocumentSnapshot<Map<String, dynamic>> userDoc =
                    await userDocumentRef.get();

                int currentWordLength = userDoc.data()?['wordLength'] ?? 0;
                int newWordLength = currentWordLength + 1;
                await userDocumentRef.update({'wordLength': newWordLength});

                DocumentSnapshot documentSnapshot = await userDocumentRef.get();
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
    );
  }

  changeLanguage() {
    formKey.currentState?.reset();
    if (inputLanguage == null) {
      inputLanguage = 'en';
      outputLanguage = 'th';
      label = "English (EN)";
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
