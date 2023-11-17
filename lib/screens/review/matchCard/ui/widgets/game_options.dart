import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/review/matchCard/ui/pages/memory_match_page.dart';
import 'package:reslate/screens/review/matchCard/ui/widgets/game_button.dart';
import 'package:reslate/screens/review/matchCard/utils/constants.dart';

class GameOptions extends StatelessWidget {
  final docID;
  const GameOptions({
    super.key,
    this.docID,
  });

  static Route<dynamic> _routeBuilder(BuildContext context, int gameLevel) {
    return MaterialPageRoute(
      builder: (_) {
        return MemoryMatchPage(gameLevel: gameLevel);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: gameLevels.map((level) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GameButton(
            onPressed: () async {
              List<Map<String, dynamic>> savedWords = (await FirebaseFirestore
                      .instance
                      .collection("Profile")
                      .doc(docID)
                      .collection("savedWords")
                      .get())
                  .docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

              if (savedWords.length >= 70) {
                Navigator.of(context).pushAndRemoveUntil(
                  _routeBuilder(context, level['level']),
                  (Route<dynamic> route) => false,
                );
              } else {
                Fluttertoast.showToast(
                    msg: "คุณมีคำศัพท์ไม่ถึง 70 คำ", gravity: ToastGravity.TOP);
              }
            },
            title: level['title'],
            color: level['color']![400]!,
            width: 250,
          ),
        );
      }).toList(),
    );
  }
}
