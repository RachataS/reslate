import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/card_item.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';

class Game {
  Game(this.gridSize) {
    getWordsList();
    matching = 24;
  }
  final int gridSize;

  List<CardItem> cards = [];
  bool isGameOver = false;
  Set<IconData> icons = {};

  var docID, wordsList;

  int matching = 24;

  Future<void> getWordsList() async {
    try {
      firebaseDoc firebasedoc = firebaseDoc();
      docID = await firebasedoc.getDocumentId();
      wordsList = await firebasedoc.getCard(docID, true);
      wordsList.shuffle(Random());

      await generateCards(wordsList);
    } catch (e) {
      print(e);
    }
  }

  Future<void> generateCards(List<Map<String, dynamic>> jsonData) async {
    cards = [];
    final List<Color> cardColors = Colors.primaries.toList();

    jsonData.shuffle(Random());

    for (int i = 0; i < (gridSize * gridSize / 2); i++) {
      final cardData = jsonData[i];
      final CardItem questionCard = CardItem(
        id: cardData['id'],
        thai: "",
        question: cardData['question'],
        color: Colors.green,
        check: i,
      );

      final CardItem thaiCard = CardItem(
        id: cardData['id'],
        thai: cardData['thai'],
        question: "",
        color: Colors.red,
        check: i,
      );

      final Color cardColor = cardColors[i % cardColors.length];
      final List<CardItem> newCards =
          _createCardItems(questionCard, thaiCard, cardColor);
      cards.addAll(newCards);
    }
    cards.shuffle(Random());
  }

  void resetGame() {
    generateCards(wordsList);
    isGameOver = false;
    matching = 24;
  }

  void onCardPressed(int index, BuildContext context) {
    if (isGameOver) {
      return; // Game is already over, no need to process further
    }

    if (cards[index].state == CardState.visible ||
        cards[index].state == CardState.guessed) {
      return;
    }

    cards[index].state = CardState.visible;
    final List<int> visibleCardIndexes = _getVisibleCardIndexes();
    if (visibleCardIndexes.length == 2) {
      final CardItem card1 = cards[visibleCardIndexes[0]];
      final CardItem card2 = cards[visibleCardIndexes[1]];

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (card1.check == card2.check) {
          card1.state = CardState.guessed;
          card2.state = CardState.guessed;
          isGameOver = _isGameOver();
        } else {
          card1.state = CardState.hidden;
          card2.state = CardState.hidden;
        }

        matching--;
        print('press $matching');

        if (matching == 0) {
          _showGameOverDialog(context);
        }
      });
    }
  }

  void _showGameOverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          title: Text(
            'Game Over',
            textAlign: TextAlign.center,
          ),
          content: Text('You ran out of presses!'),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      resetGame();
                    },
                    child: Text('Play Again'),
                  ),
                  SizedBox(width: 16), // Add some spacing between buttons
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Get.to(bottombar(), transition: Transition.topLevel);
                    },
                    child: Text('Exit'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<CardItem> _createCardItems(
      CardItem questionCard, CardItem thaiCard, Color cardColor) {
    return [
      CardItem(
          id: questionCard.id,
          thai: questionCard.thai,
          question: questionCard.question,
          state: CardState.hidden,
          color: cardColor,
          check: questionCard.check),
      CardItem(
          id: thaiCard.id,
          thai: thaiCard.thai,
          question: thaiCard.question,
          state: CardState.hidden,
          color: cardColor,
          check: questionCard.check),
    ];
  }

  List<int> _getVisibleCardIndexes() {
    return cards
        .asMap()
        .entries
        .where((entry) => entry.value.state == CardState.visible)
        .map((entry) => entry.key)
        .toList();
  }

  bool _isGameOver() {
    return cards.every((card) => card.state == CardState.guessed);
  }
}
