import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:reslate/models/profile.dart';
import 'package:reslate/screens/review/matchCard/memory_match_page.dart';
import 'package:reslate/screens/review/matchCard/widgets/game_button.dart';
import 'package:reslate/screens/review/matchCard/constants.dart';

class GameOptions extends StatelessWidget {
  final Profile profile;
  const GameOptions({super.key, required this.profile});

  static Widget _routeBuilder(BuildContext context, int gameLevel) {
    return MemoryMatchPage(gameLevel: gameLevel);
  }

  @override
  Widget build(BuildContext context) {
    int wordsLength = profile.data?['wordLength'];
    return Column(
      children: gameLevels.map((level) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GameButton(
            onPressed: () async {
              if (wordsLength >= 70) {
                Get.to(
                  () => _routeBuilder(context, level['level']),
                  transition: Transition.topLevel,
                );
              } else {
                Fluttertoast.showToast(
                    msg: "คุณมีคำศัพท์ไม่ถึง 70 คำ", gravity: ToastGravity.TOP);
              }
            },
            title: level['title'],
            color: (wordsLength >= 70 ? level['color']![400]! : Colors.red),
            width: 250,
          ),
        );
      }).toList(),
    );
  }
}
