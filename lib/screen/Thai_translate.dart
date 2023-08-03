import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';
import 'package:translator/translator.dart';

import 'Translate.dart';

class thai_translate extends StatefulWidget {
  const thai_translate({super.key});

  @override
  State<thai_translate> createState() => _thai_translateState();
}

class _thai_translateState extends State<thai_translate> {
  final formKey = GlobalKey<FormState>();
  GoogleTranslator translator = GoogleTranslator();
  String translated = "Translation";
  var save_engtxt, save_thtxt;
  var raw;
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
            Navigator.push(
                context,
                PageTransition(
                    child: translate_screen(), type: PageTransitionType.fade));
          },
        ),
      ),
      body: Card(
        key: formKey,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 200),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text("ไทย (TH)"),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: "ป้อนข้อความ",
              ),
              controller: rawtxt,
              onChanged: (rawtxt) async {
                if (rawtxt == "") {
                  translated = "Translation";
                } else {
                  try {
                    formKey.currentState?.save();
                    await translator
                        .translate(rawtxt, from: 'th', to: 'en')
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
}
