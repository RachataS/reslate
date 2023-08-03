import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:reslate/model/languageChange.dart';
import 'package:translator/translator.dart';
import 'dart:convert';

class translate_screen extends StatefulWidget {
  const translate_screen({super.key});

  @override
  State<translate_screen> createState() => _translate_screenState();
}

class _translate_screenState extends State<translate_screen> {
  final formKey = GlobalKey<FormState>();
  GoogleTranslator translator = GoogleTranslator();
  languageChange language = languageChange();
  String translated = "คำแปล";
  var save_engtxt, save_thtxt;
  var raw;
  var inputLanguage = 'en';
  var outputLanguage = 'th';
  String label = "English (EN)";
  String inputbox = "Enter text";
  String outputbox = "คำแปล";
  final rawtxt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Translate"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.translate_sharp),
          onPressed: () {
            if (inputLanguage == 'en' || inputLanguage == null) {
              language.input = 'th';
              language.output = 'en';
              language.label = "ไทย (TH)";
            } else {
              language.input = 'en';
              language.output = 'th';
              language.label = "English (EN)";
            }
            changeLanguage();
            setState(() {});
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
            save_engtxt = translated;
            save_thtxt = rawtxt.text;
            print(save_thtxt);
            print(save_engtxt);
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.save_alt_outlined),
      ),
    );
  }

  changeLanguage() {
    if (inputLanguage == null) {
      inputLanguage = 'en';
      outputLanguage = 'th';
      label = "English (EN)";
    } else {
      inputLanguage = language.input;
      outputLanguage = language.output;
      label = language.label;
    }
  }
}
