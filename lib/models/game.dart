import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:reslate/models/card_item.dart';
import 'package:reslate/models/getDocument.dart';
import 'package:reslate/screens/review/matchCard/utils/icons.dart';

class Game {
  Game(this.gridSize) {
    getWordsList();
  }
  final int gridSize;

  List<CardItem> cards = [];
  bool isGameOver = false;
  Set<IconData> icons = {};

  var docID, wordsList;

  Future<String?> getWordsList() async {
    try {
      firebaseDoc firebasedoc = firebaseDoc();
      docID = await firebasedoc.getDocumentId();
      wordsList = await firebasedoc.getQuestion(docID, true);
      generateCards(wordsList);
    } catch (e) {
      print(e);
    }
  }

  void generateCards(List<Map<String, dynamic>> jsonData) {
    cards = [];
    final List<Color> cardColors = Colors.primaries.toList();
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

  void generateIcons() {
    icons = <IconData>{};
    for (int j = 0; j < (gridSize * gridSize / 2); j++) {
      final IconData icon = _getRandomCardIcon();
      icons.add(icon);
      icons.add(icon); // Add the icon twice to ensure pairs are generated.
    }
  }

  void resetGame() {
    generateCards(wordsList);
    isGameOver = false;
  }

  void onCardPressed(int index) {
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
          print(card1.check);
        } else {
          card1.state = CardState.hidden;
          card2.state = CardState.hidden;
        }
      });
    }
  }

  List<CardItem> _createCardItems(
      CardItem questionCard, CardItem thaiCard, Color cardColor) {
    return [
      CardItem(
          id: questionCard.id,
          thai: questionCard.thai,
          question: questionCard.question,
          state: CardState.hidden,
          color: cardColor),
      CardItem(
          id: thaiCard.id,
          thai: thaiCard.thai,
          question: thaiCard.question,
          state: CardState.hidden,
          color: cardColor),
    ];
  }

  IconData _getRandomCardIcon() {
    final Random random = Random();
    IconData icon;
    do {
      icon = cardIcons[random.nextInt(cardIcons.length)];
    } while (icons.contains(icon));
    return icon;
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
