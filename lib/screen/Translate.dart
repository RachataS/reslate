import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:reslate/model/languageChange.dart';
import 'package:translator/translator.dart';
import 'dart:convert';

class translate_screen extends StatefulWidget {
  final String? docID; // Add the docID as a parameter to the constructor

  translate_screen({this.docID});

  @override
  State<translate_screen> createState() => _translate_screenState();
}

class _translate_screenState extends State<translate_screen> {
  final formKey = GlobalKey<FormState>();
  GoogleTranslator translator = GoogleTranslator();
  languageChange language = languageChange();
  String translated = "คำแปล";
  var raw;
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
    CollectionReference<Map<String, dynamic>> savedWordsCollectionRef =
        userDocumentRef.collection("savedWords");
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
              await savedWordsCollectionRef.add({
                'Eng': rawtxt.text,
                'Thai': translated,
              });
              print('Data added successfully');
            } else {
              print('Data not added: Incomplete or invalid data');
            }
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.save_alt_outlined),
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
