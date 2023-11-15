import 'package:flutter/material.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/review/multipleChoice/multipleChoice.dart';
import 'package:reslate/screens/review/matchCard/ui/pages/startup_page.dart';

class matchCard extends StatefulWidget {
  final String? docID;
  final bool? savedWordsData;

  const matchCard({this.docID, this.savedWordsData});

  @override
  State<matchCard> createState() => _matchCardState();
}

class _matchCardState extends State<matchCard> {
  firebaseDoc firebasecdoc = firebaseDoc();

  void getCard() async {
    var words =
        await firebasecdoc.getQuestion(widget.docID, widget.savedWordsData);
    print(words);
  }

  @override
  void initState() {
    super.initState();
    getCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
          //  Container(
          //   width: double.infinity,
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          //       Colors.blue[600]!,
          //       Colors.blue[300]!,
          //       Colors.blue[100]!,
          //       // Colors.blue[50]!,
          //     ]),
          //   ),
          //   child:
          MaterialApp(
        home: const StartUpPage(),
        title: 'The MemoryMatch Game',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
      ),
      // ),
    );
  }
}
