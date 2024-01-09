import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reslate/models/card_item.dart';
import 'package:reslate/controllers/getDocument.dart';
import 'package:reslate/screens/bottomBar.dart';

class Game {
  Game(this.gridSize) {
    getWordsList();
    matching = 24;
    score = 0;
  }
  final int gridSize;

  List<CardItem> cards = [];
  bool isGameOver = false;
  Set<IconData> icons = {};

  var docID, wordsList;

  int matching = 24;
  int score = 0;
  int topScore = 0;
  bool isCardMatchCheckInProgress = false;

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
        question: cardData['question'],
        color: Colors.green,
        check: i,
      );

      final CardItem thaiCard = CardItem(
        id: cardData['id'],
        question: cardData['thai'],
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
    score = 0;
  }

  void addMatchingTime() async {
    matching = matching + 10;
  }

  Future<void> onCardPressed(int index, BuildContext context) async {
    if (isGameOver || isCardMatchCheckInProgress) {
      return; // Game is already over or card match check is in progress
    }

    if (cards[index].state == CardState.visible ||
        cards[index].state == CardState.guessed) {
      return;
    }

    cards[index].state = CardState.visible;
    final List<int> visibleCardIndexes = _getVisibleCardIndexes();
    if (visibleCardIndexes.length == 2) {
      // Set the flag to indicate that card match check is in progress
      isCardMatchCheckInProgress = true;

      final CardItem card1 = cards[visibleCardIndexes[0]];
      final CardItem card2 = cards[visibleCardIndexes[1]];

      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (card1.check == card2.check) {
          card1.state = CardState.guessed;
          card2.state = CardState.guessed;
          isGameOver = _isGameOver();
          score++;
        } else {
          card1.state = CardState.hidden;
          card2.state = CardState.hidden;
        }
        // Reset the flag after the card match check is done
        isCardMatchCheckInProgress = false;
        matching--;

        if (matching == 0) {
          _showGameOverDialog(context);
          final collectionReference =
              FirebaseFirestore.instance.collection('Profile').doc(docID);

          // Fetch the current 'aids' value
          DocumentSnapshot<Map<String, dynamic>> userDocument =
              await collectionReference.get();
          int currentAids = userDocument.data()?['aids'] ?? 0;
          int level = userDocument.data()?['archiveLevel'] ?? 0;

          if (score >= 8 && score <= 15) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(1),
              });
            }
          } else if (score >= 16 && score <= 23) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(2),
              });
            }
          } else if (score >= 24) {
            if (currentAids < 3 && level <= 2) {
              await collectionReference.update({
                'aids': FieldValue.increment(3),
              });
            }
          }
        } else if (_isGameOver()) {
          // If all cards are matched, reset the game randomly
          resetGameRandomly();
        }
      });
    }
  }

  void resetGameRandomly() {
    // Shuffle the wordsList and generate new cards
    wordsList.shuffle(Random());
    generateCards(wordsList);

    // Reset the game state
    isGameOver = false;
    matching += 10;
  }

  void _showGameOverDialog(BuildContext context) async {
    await fetchTopScore();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[200]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          title: Text('Game Over',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[900]!)),
          content: SizedBox(
            height: 150,
            child: Column(children: [
              Text(
                'Top Score\n${topScore}',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Text(
                'Your score is ${score}',
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              )
            ]),
          ),
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
                    child: Text(
                      'Play Again',
                      style: TextStyle(color: Colors.blue[700]!),
                    ),
                  ),
                  SizedBox(width: 16), // Add some spacing between buttons
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Get.to(bottombar(), transition: Transition.topLevel);
                    },
                    child:
                        Text('Exit', style: TextStyle(color: Colors.red[700]!)),
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
          question: questionCard.question,
          state: CardState.hidden,
          color: cardColor,
          check: questionCard.check),
      CardItem(
          id: thaiCard.id,
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

  Future<void> fetchTopScore() async {
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await FirebaseFirestore.instance.collection("Profile").doc(docID).get();

    if (userDocument.exists) {
      topScore = await userDocument.data()?['cardTopScore'] ?? 0;
      print(topScore);
      if (topScore < score) {
        topScore = score;

        await FirebaseFirestore.instance
            .collection("Profile")
            .doc(docID)
            .update({'cardTopScore': topScore});
      }
    }
  }
}
